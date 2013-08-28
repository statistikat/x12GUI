\name{x12GUI}
\alias{x12GUI}
\title{Graphical User Interface for the S4 implementation of the X12-Arima wrapper
in package x12}
\usage{
  x12GUI(x12orig, ...)
}
\arguments{
  \item{x12orig}{object of class x12Batch or x12Single}

  \item{\dots}{further arguments (currently ignored).}
}
\description{
  GUI
}
\examples{
\dontrun{
x12path("../x12a.exe")
data(AirPassengersX12Batch)
xbn <- x12GUI(AirPassengersX12Batch)

##Create new x12Single and x12Batch objects
s1 <- new("x12Single",ts=AirPassengers,tsName="air")
s1 <- setP(s1,list(slidingspans=TRUE,history=TRUE,
  history.estimates=c("sadj","sadjchng","trend","trendchng","aic"),
  history.sadjlags=c(1,12),automdl=TRUE))
s2 <- new("x12Single",ts=ldeaths,tsName="ldeaths")
s3 <- new("x12Single",ts=UKgas,tsName="UKgas")
b <- new("x12Batch",list(s1,s2,s3))
##Use GUI to handle single object
s1 <- x12GUI(s1)
##Use GUI to handle batch object
b <- x12GUI(b)
}
}
\author{
  Daniel Schopfhauser
}
\seealso{
  \code{\link{x12}}, \code{\link{x12env}},
  \code{\linkS4class{x12Single}},
  \code{\linkS4class{x12Batch}},
  \code{\linkS4class{x12Parameter}},
  \code{\linkS4class{x12List}},
  \code{\linkS4class{x12Output}},
  \code{\linkS4class{x12BaseInfo}}, \code{\link{summary}},
  %\code{\link{summary.x12}}, \code{\link{x12work}}
}

