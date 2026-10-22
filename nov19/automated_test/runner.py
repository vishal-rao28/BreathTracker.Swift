import json
import subprocess
import time
import os
from concurrent.futures import ThreadPoolExecutor

def load_config():
    with open('automated_test/input.json', 'r') as f:
        return json.load(f)

def load_endpoints():
    with open('automated_test/endpoints.json', 'r') as f:
        return json.load(f)

def log_result(result):
    report_path = 'automated_test/report.json'
    all_results = []
    if os.path.exists(report_path):
        with open(report_path, 'r') as f:
            try:
                all_results = json.load(f)
            except:
                pass
    all_results.append(result)
    with open(report_path, 'w') as f:
        json.dump(all_results, f, indent=2)

def run_curl(url, method, data):
    # Throttle slightly
    time.sleep(0.1)
    
    cmd = ["curl", "-s", "-w", "\\n%{http_code} %{time_total}", "-X", method, url]
    if data:
        cmd.extend(["-H", "Content-Type: application/json", "-d", json.dumps(data)])
    
    start_time = time.time()
    result = subprocess.run(cmd, capture_output=True, text=True)
    duration = int((time.time() - start_time) * 1000)
    
    output = result.stdout.strip().split('\n')
    if not output:
        return "", 0, 0
    
    body = "\n".join(output[:-1])
    meta = output[-1].split()
    if len(meta) < 2:
        return body, 400, duration
    
    try:
        status = int(meta[0])
    except:
        status = 400
    return body, status, duration

def evaluate_finding(category, endpoint, body, status):
    finding = False
    note = "No vulnerability detected"
    severity = "Low"
    
    expected_role = endpoint.get('expected_role', 'public')
    
    if category == "AuthN Bypass":
        if status == 200 and "success" in body.lower():
            finding = True
            note = "Vulnerable: Protected endpoint allowed access with just an ID (unauthenticated)."
            severity = "Critical"
    
    elif category == "AuthZ / Privesc":
        if status == 200 and "success" in body.lower():
            finding = True
            note = "Vulnerable: Patient ID allowed access to Doctor-level endpoint."
            severity = "High"

    elif category == "IDOR":
        if status == 200 and "success" in body.lower():
            finding = True
            # Check if data actually changed (optional, but here IDOR is proven if success is returned for non-owned ID)
            note = "Vulnerable: Accessed another user's data record directly."
            severity = "Critical"

    return finding, note, severity

def run_test_suite(endpoint, config):
    results = []
    url = f"{config['baseUrl']}{endpoint['path']}"
    methods = endpoint['method'].split('/')
    method = methods[0]
    
    # 1. AuthN Bypass Test (if not public)
    if endpoint['expected_role'] != 'public':
        data = {"patient_id": config['patient']} if endpoint['expected_role'] == 'patient' else {"doctor_id": config['doctor']}
        body, status, dur = run_curl(url, method, data)
        f, n, s = evaluate_finding("AuthN Bypass", endpoint, body, status)
        results.append({
            "endpoint": endpoint['path'], "method": method, "role": "unauthenticated",
            "status": status, "finding": f, "severity": s, "test_category": "AuthN Bypass", "note": n,
            "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
        })

    # 2. AuthZ / Privesc Test (if doctor)
    if endpoint['expected_role'] == 'doctor':
        data = {"patient_id": config['patient']} # Try patient ID on doctor route
        body, status, dur = run_curl(url, method, data)
        f, n, s = evaluate_finding("AuthZ / Privesc", endpoint, body, status)
        results.append({
            "endpoint": endpoint['path'], "method": method, "role": "patient",
            "status": status, "finding": f, "severity": s, "test_category": "AuthZ / Privesc", "note": n,
            "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
        })

    # 3. IDOR Test (if takes patient_id)
    if endpoint['expected_role'] == 'patient':
        data = {"patient_id": config['other_patient']}
        body, status, dur = run_curl(url, method, data)
        f, n, s = evaluate_finding("IDOR", endpoint, body, status)
        results.append({
            "endpoint": endpoint['path'], "method": method, "role": "patient",
            "status": status, "finding": f, "severity": s, "test_category": "IDOR", "note": n,
            "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
        })

    return results

if __name__ == "__main__":
    if os.path.exists('automated_test/report.json'):
        os.remove('automated_test/report.json')

    config = load_config()
    endpoints = load_endpoints()
    
    final_report = []
    print(f"Starting full DAST pass on {len(endpoints)} endpoints...")
    
    # Use ThreadPoolExecutor for concurrency 5 as requested
    with ThreadPoolExecutor(max_workers=5) as executor:
        futures = {executor.submit(run_test_suite, e, config): e for e in endpoints}
        for future in futures:
            res_list = future.result()
            final_report.extend(res_list)
            print(f"Finished {futures[future]['path']}")
            
    with open('automated_test/report.json', 'w') as f:
        json.dump(final_report, f, indent=2)
    
    print(f"Full report generated with {len(final_report)} test records.")
