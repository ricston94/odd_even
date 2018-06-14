dat = read.csv("/home/richard/workspace/rts/finalproject/odd_even/data.csv", header = FALSE, sep = ",")

library("plot3D")
x <- dat$V1
y <- dat$V2
z <- dat$V3

x <- 0
y <- 0
z <- 0
# limiting z coordinate
for(i in 1:nrow(dat))
{
  if (dat$V3[i] < 2000)
  {
    x <- c(x,dat$V1[i])
    y <- c(y,dat$V2[i])
    z <- c(z,dat$V3[i])
  }
}


scatter3D(x, y, z, theta = 10, phi = 5, bty = "g",
          main = "Runtime", xlab = "No. threads",
          ylab ="Size of dataset", zlab = "Runtime [us]",
          type = "h", 
          ticktype = "detailed", pch = 19, cex = 0.5
          )

scatter3D(x, y, z, theta = 85, phi = 10, bty = "g",
          main = "Runtime", xlab = "No. threads", 
          ylab ="Size of dataset", zlab = "Runtime [us]",
          type = "h", 
          ticktype = "detailed", pch = 19, cex = 0.5)

plotdev( zlim = c(0, 5000))
library("rgl")
library("plot3Drgl")
plotrgl()
rglwidget()

