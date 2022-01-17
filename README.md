# README

Để app có thể hoạt động tốt, ta cần cài đặt ssl certificate cho localhost

$ openssl req -x509 -sha256 -nodes -newkey rsa:2048 -days 365 -keyout localhost.key -out localhost.crt

Chạy app: $ rails s -b 'ssl://localhost:3000?key=localhost.key&cert=localhost.crt'
