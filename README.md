# mock-kdc

```
docker run -it --rm -p 88:88/udp -e KRB5_REALM=EXAMPLE.COM -v $(pwd)/mock_principals:/docker-entrypoint-init.d/principals asuuto/mock-kdc:latest
```
