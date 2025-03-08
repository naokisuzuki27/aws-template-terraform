// index.js
const https = require('https');
const url = require('url');

exports.handler = async (event) => {
    // SNSからのメッセージを解析
    const message = JSON.parse(event.Records[0].Sns.Message);
    
    // アラーム情報を取得
    const alarmName = message.AlarmName;
    const alarmDescription = message.AlarmDescription;
    const newState = message.NewStateValue;
    const reason = message.NewStateReason;
    
    // アラームの重要度に基づいて色を決定
    let color = '#2eb886'; // 緑色 (OK)
    if (newState === 'ALARM') {
        color = '#dc3545'; // 赤色 (アラーム)
    } else if (newState === 'INSUFFICIENT_DATA') {
        color = '#ffc107'; // 黄色 (データ不足)
    }
    
    // Slackメッセージを作成
    const slackMessage = {
        channel: process.env.SLACK_CHANNEL,
        attachments: [
            {
                color: color,
                title: `Amazon ECS CloudWatch Alarm: ${alarmName}`,
                fields: [
                    {
                        title: 'アラーム説明',
                        value: alarmDescription,
                        short: false
                    },
                    {
                        title: '状態',
                        value: newState,
                        short: true
                    },
                    {
                        title: '理由',
                        value: reason,
                        short: false
                    },
                    {
                        title: '時刻',
                        value: new Date(message.StateChangeTime).toLocaleString('ja-JP', { timeZone: 'Asia/Tokyo' }),
                        short: true
                    }
                ],
                footer: 'Amazon CloudWatch Alarms',
                ts: Math.floor(Date.now() / 1000)
            }
        ]
    };
    
    // Slack Webhookに送信
    const webhookUrl = process.env.SLACK_WEBHOOK_URL;
    const parsedUrl = url.parse(webhookUrl);
    
    const options = {
        hostname: parsedUrl.hostname,
        path: parsedUrl.path,
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        }
    };
    
    return new Promise((resolve, reject) => {
        const req = https.request(options, (res) => {
            let data = '';
            res.on('data', (chunk) => {
                data += chunk;
            });
            res.on('end', () => {
                resolve({ statusCode: 200, body: 'Message sent to Slack' });
            });
        });
        
        req.on('error', (e) => {
            reject(e);
        });
        
        req.write(JSON.stringify(slackMessage));
        req.end();
    });
};