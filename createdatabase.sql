use mysql;

SELECT * FROM user WHERE User='root'\G
ALTER USER 'root'@'localhost' IDENTIFIED WITH 'caching_sha2_password' BY 'Testpass1$';
EXIT;
