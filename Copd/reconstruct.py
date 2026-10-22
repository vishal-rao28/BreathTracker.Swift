import re
import os

log_path = "/Users/sail/.gemini/antigravity/brain/f8351fb8-5943-4a34-9e76-44ea17709657/.system_generated/logs/overview.txt"
with open(log_path, 'r', encoding='utf-8') as f:
    content = f.read()

for line in content.splitlines():
    if "File Path:" in line:
        print(line)
