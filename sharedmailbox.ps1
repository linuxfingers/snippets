# get list of shared mailboxes in exchange online/365

Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline
Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize Unlimited | select PrimarySmtpAddress,DisplayName | Export-CSV ./sharedmb.csv


# perms

Connect-ExchangeOnline  
Get-Mailbox -RecipientTypeDetails SharedMailbox -ResultSize:Unlimited | Get-MailboxPermission |Select-Object Identity,User,AccessRights | Where-Object {($_.user -like '*@*')}|Export-Csv ./csv/sharedmailbox.csv  -NoTypeInformation 

# more perms but better

Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails SharedMailbox | Get-MailboxPermission | Select-Object Identity,User,AccessRights | Export-Csv ./csv/sharedperms.csv
