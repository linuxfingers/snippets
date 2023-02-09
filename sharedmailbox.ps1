# get list of shared mailboxes in exchange online/365

Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline
Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize Unlimited | select PrimarySmtpAddress,DisplayName | Export-CSV ./sharedmb.csv
