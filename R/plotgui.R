#sa
#trend
#log_transform
#backcast
#forecast
#showCI
#points_original
#showAllout
#span
#showOut
plotgui <- function(x,original=TRUE,sa=FALSE,trend=FALSE,
    log_transform=FALSE,
    showAllout=FALSE,showOut=NULL,
    showCI=TRUE,
    points_original=FALSE,
    span=c(1950,1,1964,12)
) 
{
  #Parameter aus vollem Plot
  ylab="Value"
  xlab="Date"
  col_original="black"
  col_sa="red"
  col_trend="green"
  lwd_original=1
  lwd_sa=1
  lwd_trend=1
  ytop=1
  showAlloutLines=TRUE
  annComp=TRUE
  annCompTrend=TRUE
  col_ao="red";col_ls="red";col_tc="red";col_annComp="grey";lwd_out=1;cex_out=1.5;
  pch_ao=4;pch_ls=2;pch_tc=23;plot_legend=TRUE;
  forecast <- backcast <- TRUE
  col_fc="#2020ff";col_bc="#2020ff";col_ci="#d1d1ff";col_cishade="#d1d1ff";
  lty_original=1;lty_fc=2;lty_bc=2;lty_ci=1;lwd_fc=1;lwd_bc=1;lwd_ci=1
  col_line="grey"
  lty_line=3
  #span wird immer gesetzt und in xlim umgerechnet
  xlim <- c(span[1]+(span[2]-1)/frequency(x@a1),span[3]+(span[4]-1)/frequency(x@a1))
  #main bestimmen
  if(original){
    if(!log_transform){
      main<-main.orig <- "Original Series"
    }else{
      main<-main.orig<- "Log transformed Original Series"
    }}
  if(sa){
    if(!log_transform){
      main<-"Seasonally Adjusted Series"	
    }else{
      main<-"Log transformed Seasonally Adjusted Series"
    }}
  if(trend){
    if(!log_transform){
      main<-"Trend"	
      
    }else{
      main<-"Log transformed Trend"
      
    }}
  if(sa && trend  &! original){
    if(!log_transform)
      main <- "Seasonally Adjusted Series and Trend"
    else
      main <- "Log transformed Seasonally Adjusted Series and Trend"
  }
  if(original && sa &!trend)	
    main <- paste(main.orig,"and Seasonally Adjusted Series")
  if(original &! sa &&trend)	
    main <- paste(main.orig,"and Trend")
  if(original && sa && trend)	
    main <- paste(main.orig,", Seasonally Adjusted Series and Trend",sep="")
  
  
  ts <- x@a1	
  fc <- x@forecast@estimate
  bc <- x@backcast@estimate
  fc.u <- x@forecast@upperci
  fc.l <- x@forecast@lowerci
  bc.u <- x@backcast@upperci
  bc.l <- x@backcast@lowerci
  
  ts.trend <- x@d12
  ts.sa <- x@d11	
  if(log_transform){
    ts <- log(ts)
    fc <- log(fc)
    bc <- log(bc)
    ts.trend <- log(ts.trend)
    ts.sa <- log(ts.sa)
    fc.u <- log(fc.u)
    bc.u <- log(bc.u)
    bc.l <- log(bc.l)
    fc.l <- log(fc.l)
  }
  if(is.na(bc[1])){
    bc <- NULL
    start <- start(ts)
  }else{
    start <- start(bc)
  }
  if(is.na(fc[1])){
    fc <- NULL
  }
  if(showCI){
    fullTs <- ts(c(bc,ts,fc,fc.l,fc.u,bc.l,bc.u),start=start,frequency=frequency(ts))
  }else{
    fullTs <- ts(c(bc,ts,fc),start=start,frequency=frequency(ts))
  }
  plot(fullTs,type="n",xlim=xlim,xlab=xlab,ylab=ylab,main=main,xaxt="n")
  aT <- aL <- axTicks(1)
  tp <- expand.grid(floor(xlim[1]):ceiling(xlim[2]),(0:(frequency(ts)-1))/frequency(ts))
  mm <- round(tp[,2]*frequency(ts))
  yy <- tp[,1]
  tp <- tp[,1]+tp[,2]
  for(i in 1:length(aT)){
    ii <- which.min(abs(tp-aT[i]))
    aT[i] <- tp[ii]
    if(mm[ii]<9)
      aL[i] <- yy[ii]+(mm[ii]+1)/10
    else
      aL[i] <- yy[ii]+(mm[ii]+1)/100
  }
  axis(1,at=aT,labels=aL)
  if(original){
    lines(ts,type="l",col=col_original,lwd=lwd_original)
    if(points_original)
      lines(ts,type="p",col=col_original,lwd=lwd_original)
    if(showCI){
      yy <- as.numeric(fc.u)
      yy <- yy[length(yy):1]
      yCI=c(as.numeric(fc.l),yy)
      xCI=c(time(fc.l),time(fc.l)[length(yy):1])
      polygon(xCI,yCI,col=col_cishade,border=NA)
      lines(fc.l,col=col_ci,lty=lty_ci,lwd=lwd_ci)
      lines(fc.u,col=col_ci,lty=lty_ci,lwd=lwd_ci)
    }
    if(points_original&&!is.null(bc))
      lines(bc,col=col_bc,lty=lty_bc,type="p")
    if(points_original&&!is.null(fc))
      lines(fc,col=col_fc,lty=lty_fc,type="p")
    if(!is.null(bc)){
      bc1 <- ts(c(window(ts,start=start(ts),end=start(ts)),bc),start=start(bc),frequency=frequency(ts))
      lines(bc,col=col_bc,lty=lty_bc)
    }
    if(!is.null(fc)){
      fc1 <- ts(c(window(ts,start=end(ts),end=end(ts)),fc),start=end(ts),frequency=frequency(ts))
      lines(fc1,col=col_fc,lty=lty_fc)
    }
    
  }
  if(sa){
    lines(ts.sa,type="l",col=col_sa,lwd=lwd_sa)
  }
  if(trend){
    lines(ts.trend,type="l",col=col_trend,lwd=lwd_trend)
  }
  if(!is.null(showOut)){
    showOutDate <- as.numeric(unlist(strsplit(showOut,"\\.")))
    showOutVal <- window(ts,start=showOutDate,end=showOutDate)
    lines(showOutVal,col=col_ao,type="p",pch=8,cex=cex_out)
    abline(v=time(showOutVal),col=col_ao,lty=lty_line)
    datesALL <- (floor(xlim[1]):ceiling(xlim[2]))+(showOutDate[2]-1)/frequency(ts)
    oval <- tval <- vector()
    
    for(i in 1:length(datesALL)){
      abline(v=datesALL[i],col=col_line,lty=lty_line)
      dat <- c(floor(datesALL[i]),showOutDate[2])
      if(tsp(ts)[2]>=datesALL[i]){
        oval <- c(oval,window(ts,start=dat,end=dat))
        tval <- c(tval,datesALL[i])
      }
    }
    lines(tval,oval,col=col_line)
  }else if(showAllout){
      names.out <- vector()
      if(any(x@dg$outlier!="-")){
        names.out <- names(x@dg$outlier)
        names.out <- tolower(gsub("outlier_","",names.out))
      }
      if(any(x@dg$autoout!="-")){
          names.out <- c(names.out,tolower(gsub("autooutlier_","",names(x@dg$autoout))))
      }
      mm <- c("jan","feb","mar","apr","may","jun","jul","aug","sep","oct","nov","dec")
      for(i in 1:12){
        names.out <- str_replace(names.out,mm[i],as.character(i))
      }
      if(length(names.out)>0){
        types <- substr(names.out,1,2)
        years <- as.numeric(substr(names.out,3,6))
        months <- as.numeric(substr(names.out,8,12))
        vals <- apply(cbind(years,months),1,function(x)window(ts,start=c(x[1],x[2]),end=c(x[1],x[2])))
        times <- years+(months-1)/frequency(ts)
        cols <- rep(col_ao,length(types))
        cols[types=="ls"] <- col_ls
        cols[types=="tc"] <- col_tc
        pchs <- rep(pch_ao,length(types))
        pchs[types=="ls"] <- pch_ls
        pchs[types=="tc"] <- pch_tc
        points(times,vals,pch=pchs,col=cols,cex=cex_out)
      }
	putKeyEmpty.New(time(na.omit(fullTs)),na.omit(fullTs),labels=c("AO","LS","TC"),type="p",pch=c(4,2,23),col="red")
	  
  }
  
}


######
"putKeyEmpty.New"<-function (x, y, labels, type = NULL, pch = NULL, lty = NULL, 
		lwd = NULL, cex = par("cex"), col = rep(par("col"), nc), 
		transparent = TRUE, plot = TRUE, key.opts = NULL, empty.method = c("area", 
				"maxdim"), numbins = 25, xlim = pr$usr[1:2], ylim = pr$usr[3:4], 
		grid = FALSE) 
{
	nc <- length(labels)
	empty.method <- match.arg(empty.method)
	pr <- parGrid(grid)
	uin <- pr$uin
	if (.R.) 
		uin <- 1
	z <- putKey.New(list(0, 0), labels, type, pch, lty, lwd, cex, 
			col, transparent = transparent, plot = FALSE, key.opts = key.opts, 
			grid = grid)/uin
	s <- is.finite(x + y)
	if (length(xlim)) 
		s <- s & (x >= xlim[1] & x <= xlim[2])
	if (length(ylim)) 
		s <- s & (y >= ylim[1] & y <= ylim[2])
	x <- x[s]
	y <- y[s]
	keyloc <- largest.empty(x, y, xlim = xlim, ylim = ylim, width = z[1], 
			height = z[2], method = empty.method, numbins = numbins, 
			grid = grid)
	if (is.na(keyloc$x)) {
		cat("No empty area large enough for automatic key positioning.  Specify keyloc or cex.\n")
		cat("Width and height of key as computed by key(), in data units:", 
				format(z), "\n")
		return(keyloc)
	}
	else if (plot) 
		putKey.New(keyloc, labels, type, pch, lty, lwd, cex, col, 
				transparent, plot = TRUE, key.opts = key.opts, grid = grid)
	invisible(keyloc)
}

"putKey.New" <- function (z, labels, type = NULL, pch = NULL, lty = NULL, lwd = NULL, 
		cex = par("cex"), col = rep(par("col"), nc), transparent = TRUE, 
		plot = TRUE, key.opts = NULL, grid = FALSE) 
{
	if (!.R. && !existsFunction("key")) 
		stop("must do library(trellis) to access key() function")
	nc <- length(labels)
	if (!length(pch)) 
		pch <- rep(NA, nc)
	if (!length(lty)) 
		lty <- rep(NA, nc)
	if (!length(lwd)) 
		lwd <- rep(NA, nc)
#	pp <- !is.na(pch)
#	lp <- !is.na(lty) | !is.na(lwd)
#	lwd <- ifelse(is.na(lwd), par("lwd"), lwd)
#	if (!length(type)) 
#		type <- ifelse(!(pp | lp), "n", ifelse(pp & lp, "b", 
#						ifelse(pp, "p", "l")))
#	pch <- ifelse(is.na(pch) & type != "p" & type != "b", if (.R.) 
#						NA
#					else 0, pch)
#	lty <- ifelse(is.na(lty) & type == "p", if (.R.) 
#						NA
#					else 1, lty)
#	lwd <- ifelse(is.na(lwd) & type == "p", 1, lwd)
#	cex <- ifelse(is.na(cex) & type != "p" & type != "b", 1, 
#			cex)
#	if (!.R. && any(is.na(pch))) 
#		stop("pch can not be NA for type='p' or 'b'")
#	if (!.R. && any(is.na(lty))) 
#		stop("lty can not be NA for type='l' or 'b'")
#	if (any(is.na(lwd))) 
#		stop("lwd can not be NA for type='l' or 'b'")
#	if (any(is.na(cex))) 
#		stop("cex can not be NA for type='p' or 'b'")
	m <- list()
	m[[1]] <- as.name(if (grid) 
						"draw.key"
					else if (.R.) 
						"rlegend"
					else "key")
	if (!grid) {
		m$x <- z[[1]]
		m$y <- z[[2]]
	}
	if (.R.) {
		if (grid) {
			w <- list(text = list(labels, col = col))
			if (!(all(is.na(lty)) & all(is.na(lwd)))) {
				lns <- list()
				if (!all(is.na(lty))) 
					lns$lty <- lty
				if (!all(is.na(lwd))) 
					lns$lwd <- lwd
				lns$col <- col
				w$lines <- lns
			}
			if (!all(is.na(pch))) 
				w$points <- list(pch = pch, col = col)
			m$key <- c(w, key.opts)
			m$draw <- plot
			if (plot) 
				m$vp <- viewport(x = unit(z[[1]], "native"), 
						y = unit(z[[2]], "native"))
			z <- eval(as.call(m))
			size <- if (plot) 
						c(NA, NA)
					else c(convertUnit(grobWidth(z), "native", "x", "location", 
										"x", "dimension", valueOnly = TRUE)[1], convertUnit(grobHeight(z), 
										"native", "y", "location", "y", "dimension", 
										valueOnly = TRUE)[1])
			return(invisible(size))
		}
		else {
			m$legend <- labels
			m$xjust <- m$yjust <- 0.5
			m$plot <- plot
			m$col <- col
			m$cex <- cex
			if (!all(is.na(lty))) 
				m$lty <- lty
			if (!all(is.na(lwd))) 
				m$lwd <- lwd
			if (!all(is.na(pch))) 
				m$pch <- pch
			if (length(key.opts)) 
				m[names(key.opts)] <- key.opts
			w <- eval(as.call(m))$rect
			return(invisible(c(w$w[1], w$h[1])))
		}
	}
	m$transparent <- transparent
	m$corner <- c(0.5, 0.5)
	m$plot <- plot
	m$type <- type
	if (!plot) 
		labels <- substring(labels, 1, 10)
	m$text <- list(labels, col = col)
	if (all(type == "p")) 
		m$points <- list(pch = pch, cex = cex, col = col)
	else m$lines <- if (any(type != "l")) 
					list(lty = lty, col = col, lwd = lwd, pch = pch, cex = cex)
				else list(lty = lty, col = col, lwd = lwd)
	if (length(key.opts)) 
		m[names(key.opts)] <- key.opts
	invisible(eval(as.call(m)))
}
