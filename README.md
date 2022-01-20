# README

Để app có thể hoạt động tốt ta cần thiết lập https cho localhost, ta dùng cú pháp sau:

$> openssl req -x509 -sha256 -nodes -newkey rsa:2048 -days 365 -keyout localhost.key -out localhost.crt

$> rails s -b 'ssl://localhost:3000?key=localhost.key&cert=localhost.crt'
