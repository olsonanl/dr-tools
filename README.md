# Datarobot API tools

## Command line tools

The DataRobot tools require an authentication token. The `dr-login` script creates
a token that is stored in a file .datarobot_token in your home directory:

```
  $ dr-login usernamame password
  Got {"apiToken": "9XXXX-YYYYY"}
```