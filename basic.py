from flask import Flask, render_template, request
from flask_sqlalchemy import SQLAlchemy

import pandas as pd

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///site.db'

db = SQLAlchemy(app)

input_data = pd.read_csv("input_data.csv")
all_movies = list(input_data['title'])
all_movies.sort()

@app.route('/')
def index():
	return render_template("base.html", all_movies = all_movies)

class Movie(db.Model):

	id = db.Column(db.Integer, primary_key = True)
	name = db.Column(db.String(20), unique = True, nullable = False)
	image_file = db.Column(db.String(300), unique = True, nullable = False)

	def __repr__(self):
		return "Movie(%s, %s)" % (self.name, self.image_file)

class Recommendation(db.Model):

	id = db.Column(db.Integer, primary_key = True)
	name = db.Column(db.String(20), unique = True, nullable = False)
	rec_1 = db.Column(db.String(20), nullable = False)
	rec_2 = db.Column(db.String(20), nullable = False)
	rec_3 = db.Column(db.String(20), nullable = False)
	rec_4 = db.Column(db.String(20), nullable = False)
	rec_5 = db.Column(db.String(20), nullable = False)

db.create_all()

def get_movies_list(movie_name):

	recommended_list = []
	for i in range(1, 6):
		exec("recommended_list.append((Recommendation.query.filter_by(name = movie_name).all()[0].rec_" 
			+ str(i) + "))")

	return recommended_list

# print(get_movies_list("The Shawshank Redemption"))

def get_poster_urls(recommended_list):

	poster_urls = []
	for mov in recommended_list:
		poster_urls.append(Movie.query.filter_by(name = mov).all()[0].image_file)

	return poster_urls

# all_movies.sort()

# Get movie name from form
@app.route('/handle_data', methods=['POST'])
def handle_data():
	movie_name = request.form['movie_name']
	# print(movie_name)
	
	global all_movies
	'''
	Search in recos.csv for movie_name and return movie objects
	'''
	recommended_list = get_movies_list(movie_name)
	'''
	For each movie in the list, get the image and display it
	'''
	movie_poster_list = get_poster_urls(recommended_list)

	return render_template("base.html", movie_name = movie_name, movie_poster_list = movie_poster_list,
		all_movies = all_movies, recommended_list = recommended_list)

def populate_database():

	data = pd.read_csv("input_data.csv")

	all_movies = data['title']

	for index, row in data.iterrows():

		temp_movie = Movie(name = (row['title']), 
			image_file = str(row['poster']))
		db.session.add(temp_movie)

	db.session.commit()

def populate_recos():

	data = pd.read_csv("temp_recos.csv")

	for index, row in data.iterrows():

		if index == 0:
			continue

		temp = Recommendation(name = row['V1'], rec_1 = row['V2'],
			rec_2 = row['V3'], rec_3 = row['V4'], rec_4 = row['V5'],
			rec_5 = row['V6'])		
		db.session.add(temp)

	db.session.commit()

# populate_database()
# populate_recos()

if __name__ == "__main__":
	app.run(debug = True)