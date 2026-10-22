#!/usr/bin/env python3
import os
import json
import re

def discover_endpoints(directory):
    endpoints = []
    exclude_files = ['config.php', 'test_db.php', 'vaccine_log.txt', 'fetch_medication_diary.txt']
    exclude_dirs = ['automated_test', 'automated test', 'uploads', '.git', '.agent']

    for root, dirs, files in os.walk(directory):
        # Skip excluded directories
        dirs[:] = [d for d in dirs if d not in exclude_dirs]
        
        for file in files:
            if file.endswith('.php') and file not in exclude_files:
                path = os.path.relpath(os.path.join(root, file), directory)
                endpoint_url = '/' + path
                
                # Try to determine method
                method = "POST" # Default for this project based on observation
                try:
                    with open(os.path.join(root, file), 'r') as f:
                        content = f.read()
                        if 'header("Access-Control-Allow-Methods: GET")' in content:
                            method = "GET"
                        elif 'Access-Control-Allow-Methods: POST, GET' in content or 'Access-Control-Allow-Methods: GET, POST' in content:
                            method = "POST/GET"
                except:
                    pass
                
                # Determine expected access role
                role = "public"
                if "patient" in file or "save_" in file or "submit_" in file or "get_my_copd" in file or "get_patient" in file:
                    role = "patient"
                if "doctor" in file or "fetch_doctor_patients" in file or "get_patients.php" in file:
                    role = "doctor"
                if "login" in file or "signup" in file or "register" in file or "forgot_password" in file or "verify_patient" in file:
                    role = "public"
                
                endpoints.append({
                    "path": endpoint_url,
                    "method": method,
                    "expected_role": role
                })
    
    return endpoints

if __name__ == "__main__":
    base_dir = os.getcwd()
    endpoints = discover_endpoints(base_dir)
    # Filter health/actuator/metrics as requested
    endpoints = [e for e in endpoints if not any(x in e['path'] for x in ['/health', '/actuator', '/metrics'])]
    
    print(f"Discovered {len(endpoints)} endpoints:")
    for e in endpoints:
        print(f"- {e['method']} {e['path']} (Expected: {e['expected_role']})")
    
    with open('automated_test/endpoints.json', 'w') as f:
        json.dump(endpoints, f, indent=2)
