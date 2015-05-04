#!/usr/bin/python

import smtplib
import datetime

debuglevel = 0
smtp_server_ip='10.243.17.61'

sender = 'jim_lin@quantatw.com'
receivers = ['jim_lin@quantatw.com','jimlin.qci@gmail.com','jim_lin@quantatw.com']

dailybuild_sender='LCBU@quantatw.com'
subj = "Daily Build report!!!"

format="MIME-Version: 1.0\nContent-type: text/html\n"

message_text="""
This is an e-mail message to be sent in HTML format

<b>This is HTML message.</b>
<h1>This is headline.</h1>
"""
message = "From: %s\nSubject: %s\n%s\n%s" % ( dailybuild_sender, subj,format, message_text )

smtpObj = smtplib.SMTP(smtp_server_ip)
smtpObj.sendmail(sender, receivers, message)         
smtpObj.set_debuglevel(debuglevel)
print "Successfully sent email"


