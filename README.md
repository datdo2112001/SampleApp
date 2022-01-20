# README

Để app hoạt động được ta cần chuyển localhost từ http sang https
$> openssl req -x509 -sha256 -nodes -newkey rsa:2048 -days 365 -keyout localhost.key -out localhost.crt
$> rails s -b 'ssl://localhost:3000?key=localhost.key&cert=localhost.crt'
