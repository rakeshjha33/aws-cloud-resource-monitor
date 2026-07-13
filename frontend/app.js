// Replace with your API Gateway GET endpoint URL
const FETCH_URL = "https://t6hyszbfz5.execute-api.ap-southeast-2.amazonaws.com/tracker";

async function fetchTelemetry() {
    try {
        const response = await fetch(FETCH_URL);
        const data = await response.json();
        
        // Target object structure matches the DynamoDB payload mapped in Lambda
        const item = data.Item || data; 
        
        // Update Timestamps & Counters
        document.getElementById('last-updated').innerText = `Last updated: ${new Date(item.timestamp).toLocaleString()}`;
        
        // Handle variations of nesting depending on how CLI parsed it
        const ec2List = item.ec2?.flat() || [];
        document.getElementById('ec2-count').innerText = ec2List.length;
        document.getElementById('s3-count').innerText = item.s3?.length || 0;
        document.getElementById('lambda-count').innerText = item.lambda?.length || 0;
        document.getElementById('iam-count').innerText = item.iam?.length || 0;
        
        // Render simple scannable HTML blocks for data preview
        let htmlContent = `
            <div>
                <h4 class="text-sm font-bold text-slate-300 underline mb-2">Active EC2 Nodes</h4>
                <ul class="list-disc pl-5 text-sm text-slate-400">${ec2List.map(e => `<li><code>${e.ID}</code> - ${e.Type} (${e.State})</li>`).join('') || 'None detected'}</ul>
            </div>
            <div class="mt-4">
                <h4 class="text-sm font-bold text-slate-300 underline mb-2">S3 Cloud Storage</h4>
                <ul class="list-disc pl-5 text-sm text-slate-400">${item.s3?.map(s => `<li>${s.Name}</li>`).join('') || 'None detected'}</ul>
            </div>
        `;
        document.getElementById('inventory-lists').innerHTML = htmlContent;

    } catch (error) {
        console.error("Error pulling architecture telemetry: ", error);
        document.getElementById('last-updated').innerText = "Failed to synchronize status.";
    }
}

// Polling intervals for clean dashboards
fetchTelemetry();
setInterval(fetchTelemetry, 30000); // refresh every 30 seconds
