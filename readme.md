```
netstat -aon | findstr '[port_number]'
tasklist | findstr '[PID]'
```
```
docker build -t light-server .
docker run -d --rm --name light-server -p 80:80 light-server
```
- localhost/
- localhost/api/fast
- localhost/api/slow
