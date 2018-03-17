import json
import requests
import re

ProductID = "test"
Security_Profile_Description = "test"
Security_Profile_ID = "amzn1.application.1e5e1881dea04db58f3ee89ae953eeb2"
Client_ID = "amzn1.application-oa2-client.62d2fef790244a9c9276fc42a6314950"
Client_Secret = "6afa76a4a1082ed32b26a7f6780963aa6f8a04d0a63964afb0007cfde0270111"
refresh_token = "Atzr|IwEBINGAodV0ucV74csbeIXLbO_o-uoc5nnvCwLVhObNzS1w-hToPYx2TGvOok2W5xLXn2Yd2QWVlLQHonSdrA7cVHmE_MIEjZyK7AgaCt25D14Y0j-km7fQa3vtcZDh46dy-ULEGsnbLQgSNXj_g-gIHwzZFqYbY-C7ktwfaKomU2y4KoXinheCLwXhAiK_O2fmPbVdP1vX87nRKQTPinYdwp_Fv9uEMDlHgIg_43-lmg6H2GS0P0v4UxY_hSOmb70eAdbGCzdJpQ6oOIvCyog3vuOCHWLgwnNQGYWF-ln9MNLUZpWcJ1EINFUyQ4ra3HmPgjz3xDFuTnsgrDdfQPFDipIC5EXNG13ZeItdcgPkY07GzgfZI1lCylHvkpULjoexjJoh5OP7m6lH3p0cLE9IMifQUXCFmSWJuI07XBSEW7SpR77EeOMY7132JS9nTC62NGFVoJGGEm5uGJQhktCQXHV8OAEVwXXbFedArVt9Gh1ih-D5yn7UJKVso1f8sOl4XVvnnY3z_AvFwWq0QfmMHDtD"


Client_ID = "amzn1.application-oa2-client.62d2fef790244a9c9276fc42a6314950"
Client_Secret = "6afa76a4a1082ed32b26a7f6780963aa6f8a04d0a63964afb0007cfde0270111"
refresh = "Atzr|IwEBINGAodV0ucV74csbeIXLbO_o-uoc5nnvCwLVhObNzS1w-hToPYx2TGvOok2W5xLXn2Yd2QWVlLQHonSdrA7cVHmE_MIEjZyK7AgaCt25D14Y0j-km7fQa3vtcZDh46dy-ULEGsnbLQgSNXj_g-gIHwzZFqYbY-C7ktwfaKomU2y4KoXinheCLwXhAiK_O2fmPbVdP1vX87nRKQTPinYdwp_Fv9uEMDlHgIg_43-lmg6H2GS0P0v4UxY_hSOmb70eAdbGCzdJpQ6oOIvCyog3vuOCHWLgwnNQGYWF-ln9MNLUZpWcJ1EINFUyQ4ra3HmPgjz3xDFuTnsgrDdfQPFDipIC5EXNG13ZeItdcgPkY07GzgfZI1lCylHvkpULjoexjJoh5OP7m6lH3p0cLE9IMifQUXCFmSWJuI07XBSEW7SpR77EeOMY7132JS9nTC62NGFVoJGGEm5uGJQhktCQXHV8OAEVwXXbFedArVt9Gh1ih-D5yn7UJKVso1f8sOl4XVvnnY3z_AvFwWq0QfmMHDtD"

def json_string_value(json_r, item):
	m = re.search('(?<={}":")(.*?)(?=")'.format(item), json_r)
	if m:
		return m.group(0)
	else:
		return ""

def gettoken():
	payload = {"client_id" : Client_ID, "client_secret" : Client_Secret, "refresh_token" : refresh, "grant_type" : "refresh_token", }
	url = "https://api.amazon.com/auth/o2/token"
	r = requests.post(url, data = payload)
	resp = json.loads(r.text)
	t = resp['access_token']
	print(t)
	return t

def asr():
	# https://developer.amazon.com/public/solutions/alexa/alexa-voice-service/rest/speechrecognizer-requests
	# if debug: print("{}Sending Speech Request...{}".format(bcolors.OKBLUE, bcolors.ENDC))
	# GPIO.output(plb_light, GPIO.HIGH)
	url = 'https://access-alexa-na.amazon.com/v1/avs/speechrecognizer/recognize'
	headers = {'Authorization' : 'Bearer %s' % gettoken()}
	d = {
		"messageHeader": {
			"deviceContext": [
				{
					"name": "playbackState",
					"namespace": "AudioPlayer",
					"payload": {
					"streamId": "",
						"offsetInMilliseconds": "0",
						"playerActivity": "IDLE"
					}
				}
			]
		},
		"messageBody": {
			"profile": "alexa-close-talk",
			"locale": "en-us",
			"format": "audio/L16; rate=16000; channels=1"
		}
	}
	with open('./input.wav') as inf:
		files = [
				('file', ('request', json.dumps(d), 'application/json; charset=UTF-8')),
				('file', ('audio', inf, 'audio/L16; rate=16000; channels=1'))
				]
		r = requests.post(url, headers=headers, files=files)
		
	return r

def result(r):
	global nav_token, streamurl, streamid, audioplaying
	
	nav_token = ""
	streamurl = ""
	streamid = ""

	if r.status_code == 200:
		for v in r.headers['content-type'].split(";"):
			if re.match('.*boundary.*', v):
				boundary = v.split("=")[1]
		data = r.content.split(boundary)
		n = re.search('(?=audio\/mpeg)(.*?)(?=\r\n)', r.content)
		r.connection.close()
		audio = ""
		for d in data:
			m = re.search('(?<=Content\-Type: )(.*?)(?=\r\n)', d)
			if m:
				c_type = m.group(0)
				if c_type == 'application/json':
					print(d)
					print("\n\n")
					json_r = d.split('\r\n\r\n')[1].rstrip('\r\n--')
					
					nav_token = json_string_value(json_r, "navigationToken")
					streamurl = json_string_value(json_r, "streamUrl")
					print(streamurl)
					if json_r.find('"progressReportRequired":false') == -1:
						streamid = json_string_value(json_r, "streamId")
					if streamurl.find("cid:") == 0:		
						streamurl = ""
					playBehavior = json_string_value(json_r, "playBehavior")
					if n == None and streamurl != "" and streamid.find("cid:") == -1:

						return
					if json_r.find('"namespace": "Speaker"') == -1:
						# User requested an audio output change
						adjustmentType = json_string_value(json_r, "adjustmentType")
						if adjustmentType:
							level = json_integer_value(json_r, "volume")
							
				elif c_type == 'audio/mpeg':

					audio = d.split('\r\n\r\n')[1].rstrip('--')
					if audio != "":
						with open("./response.mp3", 'wb') as f:
							f.write(audio)
				else:
					print "*** Unknown Content Type: ", c_type

result(asr())
