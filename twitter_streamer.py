import twitter_credentials as tc
import tweepy
from pymongo import MongoClient
from pymongo import errors
import json
from dateutil import parser



try:
	conn = MongoClient()
	print("Connected successfully!!!")
except errors as e:
	print(e)

db = conn.covid_tweets_db

collection = db.covid_tweets_collection


def connect(username, created_at, tweet, location):

	record = {"username": username, "created_at": created_at, "tweet": tweet, "location": location}

	record_id = collection.insert_one(record)

	print(record_id)



class MyStreamListener(tweepy.StreamListener):

	def on_connect(self):
		print("You are connected to twitter API")

	def on_data(self, data):

		print(data)
		try:
			raw_data = json.loads(data)

			if 'text' in raw_data:

				username = raw_data['user']['screen_name']
				created_at = parser.parse(raw_data['created_at'])
				tweet = raw_data['text']

				if raw_data['place'] is not None:
					place = raw_data['place']['country']
					print(place)
				else:
					place = None

				location = raw_data['user']['location']
				connect(username, created_at, tweet, location)

		except:
			print("error")


if __name__ == '__main__':

	auth = tweepy.OAuthHandler(tc.CONSUMER_KEY, tc.CONSUMER_SECRET)
	auth.set_access_token(tc.ACCESS_TOKEN, tc.ACCESS_TOKEN_SECRET)
	api = tweepy.API(auth)

	listener = MyStreamListener()
	stream = tweepy.Stream(auth, listener=listener)

	track = ['#Covid19', '#Coronavirus', '#Lockdown', '#StaySafeStayHome', '#safehands', '#socialdistancing', '#FlattenTheCurve', '#WorkingFromHome']

	stream.filter(track=track, languages=['en'])

