setwd("D:/R")
dataset = read.csv("input_data.csv", stringsAsFactors = F)

temp = dataset

temp$votes = as.numeric(gsub(",", "", temp$votes))

temp$description = NULL
temp$poster = NULL
temp$release_date
temp$release_date = NULL
temp$storyline = NULL
temp$gallery.0 = NULL

temp$gallery.1 = NULL
temp$gallery.2 = NULL
temp$gallery.3 = NULL
temp$gallery.4 = NULL

temp$running_time = as.numeric(gsub(" min", "", temp$running_time))

temp$metascore[is.na(temp$metascore)] = median(temp$metascore, na.rm = T)

unique_director = unique(temp$director)
unique_director = sort(unique_director)
director_indices = sapply(temp$director, match, unique_director)
director_features = sapply(director_indices, generateDirectorFeatures)
director_features = as.data.frame(t(director_features))
rownames(director_features) = temp$title
colnames(director_features) = unique_director

stars = c(temp$stars.0, temp$stars.1, temp$stars.2)
unique_stars = unique(stars)
unique_stars = sort(unique_stars)
stars_indices0 = sapply(temp$stars.0, match, unique_stars)
stars_indices1 = sapply(temp$stars.1, match, unique_stars)
stars_indices2 = sapply(temp$stars.2, match, unique_stars)
stars_indices = as.data.frame(cbind(stars_indices0, stars_indices1, stars_indices2))
stars_features = apply(stars_indices, 1, generateStarsFeatures)
stars_features = t(stars_features)
stars_features = as.data.frame(stars_features)
colnames(stars_features) = unique_stars
rownames(stars_features) = temp$title

genre = c(temp$genre.0, temp$genre.1, temp$genre.2)
unique_genre = unique(genre)
unique_genre = sort(unique_genre)
unique_genre = unique_genre[-1]
genre_indices0 = sapply(temp$genre.0, match, unique_genre)
genre_indices1 = sapply(temp$genre.1, match, unique_genre)
genre_indices2 = sapply(temp$genre.2, match, unique_genre)
genre_indices = as.data.frame(cbind(genre_indices0, genre_indices1, genre_indices2))
genre_features = apply(genre_indices, 1, generateGenreFeatures)
genre_features = as.data.frame(t(genre_features))
colnames(genre_features) = unique_genre
rownames(genre_features) = temp$title

movie_vector = as.data.frame(cbind(director_features, stars_features, genre_features, temp$rating, temp$votes, temp$metascore))
movie_vector = movie_vector[-743]
movie_vector = scale(movie_vector)

cosine_values = cosine(t(movie_vector))
top10 = t(apply(cosine_values, 1, function(x) order(-x)[1:11]))

recos = rep('', 11)
for(i in 1:250) { recos = rbind(recos, temp$title[top10[i, ]]) }
write.csv(recos, file = "recos.csv")


