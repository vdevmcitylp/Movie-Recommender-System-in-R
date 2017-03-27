
generateDirectorFeatures <- function(index) {
  z = rep(0, 145)
  z[index] = 1
  return(z)
}

generateStarsFeatures <- function(index) {
  z = rep(0, 576)
  z[index] = 1
  return(z)
}

generateGenreFeatures <- function(index) {
  z = rep(0, 22)
  z[index] = 1
  return(z)
}

