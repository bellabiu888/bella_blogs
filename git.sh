

#!/usr/bin/env bash
set -e

message="${1:-更新博客}"
git add .
git commit -m "$message"
git push
