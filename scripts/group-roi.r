library(ggplot2)
library(plyr)
library(grid)
library(xtable)


center <- function(x, around=0) x - mean(x) + around


args <- commandArgs(TRUE)
ROI_RESULTS_DIR <- args[1]
SUBJ_ROI_DIR <- args[2]
subjects <- args[3:length(args)]

save(subjects,SUBJ_ROI_DIR, file = 'roivars.Rdat')

plot.mean.firs <- function(data, output_dir) {
	N <- length(unique(data$subj))
	# we compute the mean and within-subjects standard deviation for each lag x run x hemisphere x region, by taking the mean across trials for each of those, centering those means for each subject to make them comparable, and taking the sds across subjects divided by sqrt(N) to get the se
	sxc.means <- ddply(data, c('subj', 'run', 'lag', 'hemisphere', 'region'), summarise, pe=mean(pe))
	centered <- ddply(sxc.means, c('subj', 'lag', 'hemisphere', 'region'), function(X) data.frame(run=X$run, 	pe=center(X$pe)))
	ses <- ddply(centered, c('run', 'lag', 'hemisphere', 'region'), function(X) data.frame(se=sd(X$pe)/sqrt(N)))
	means <- ddply(data, c('run', 'lag', 'hemisphere', 'region'), summarise, mean=mean(pe))
	summ <- cbind(ses, mean=means$mean)


	# for each region and hemisphere, plot a line connecting each condition's mean, with standard error bars at each point, dodged so they don't overlap:
	p <- ggplot(aes(x=lag, y=mean, color=run), data=summ) + facet_grid(region ~ hemisphere) + ylab('parameter estimate')
	p <- p + geom_line()
	#p <- p + geom_linerange(aes(ymin=mean-se, ymax=mean+se), position=position_dodge(w=0.2))
	#p <- p + opts(title='mean parameter estimates\nw/ error bars to +/- 1 within-subjects S.E.\n dodged to prevent overlap')
	p <- p + geom_ribbon(aes(ymin=mean-se, ymax=mean+se), alpha=I(1/4))
	p <- p + opts(title='mean parameter estimates\nw/ error ribbons to +/- 1 within-subjects S.E.')
	ggsave(paste(output_dir, 'fir_plot.pdf', sep='/'), plot=p, width=9, height=6)
}


plot.mean.firs.collapsed.across.hemisphere <- function(data, output_dir) {
	N <- length(unique(data$subj))
	# we compute the mean and within-subjects standard deviation for each lag x condition x region, by taking the mean across trials for each of those, centering those means for each subject to make them comparable, and taking the sds across subjects divided by sqrt(N) to get the se
	sxc.means <- ddply(data, c('subj', 'run', 'lag', 'region'), summarise, pe=mean(pe))
	centered <- ddply(sxc.means, c('subj', 'lag', 'region'), function(X) data.frame(run=X$run, 	pe=center(X$pe)))
	ses <- ddply(centered, c('run', 'lag', 'region'), function(X) data.frame(se=sd(X$pe)/sqrt(N)))
	means <- ddply(data, c('run', 'lag', 'region'), summarise, mean=mean(pe))
	summ <- cbind(ses, mean=means$mean)


	# for each region and hemisphere, plot a line connecting each condition's mean, with standard error bars at each point, dodged so they don't overlap:
	p <- ggplot(aes(x=lag, y=mean, color=run), data=summ) + facet_grid(region ~ .) + ylab('parameter estimate')
	p <- p + geom_line()
	#p <- p + geom_linerange(aes(ymin=mean-se, ymax=mean+se), position=position_dodge(w=0.2))
	#p <- p + opts(title='mean parameter estimates\nw/ error bars to +/- 1 within-subjects S.E.\n dodged to prevent overlap')
	p <- p + geom_ribbon(aes(ymin=mean-se, ymax=mean+se), alpha=I(1/4))
	p <- p + opts(title='mean parameter estimates\nw/ error ribbons to +/- 1 within-subjects S.E.')
	ggsave(paste(output_dir, 'fir_plot_hemi_averaged.pdf', sep='/'), plot=p, width=9, height=6)
}


plot.small.multiple.firs <- function(data, output_dir) {
	# for each subject x run, plot a line connecting the mean of each condition
	runs <- unique(data$run)
	subjs <- unique(data$subj)
	
	theme_bare <- opts(plot.title=theme_blank(),
	
					   axis.line=theme_blank(),
					   axis.text.x=theme_blank(),
					   axis.text.y=theme_blank(),
					   axis.ticks=theme_blank(),
					   axis.title.x=theme_blank(),
					   axis.title.y=theme_blank(),
					   
					   legend.position='none',
					   
					   strip.background=theme_blank(),
					   strip.text.x=theme_blank(),
					   strip.text.y=theme_blank(),
					   
					   plot.margin=unit(rep(0,4), 'lines'))
	
	# this grid code is from ggplot2 book pg.154
	pdf(paste(output_dir, 'fir_small_mults.pdf', sep='/'), height=2*length(subjs))
	grid.newpage()
	pushViewport(viewport(layout=grid.layout(length(subjs), length(runs))))
	vplayout <- function(row, col)
		viewport(layout.pos.row=row, layout.pos.col=col)
	
	for (s in 1:length(subjs)) {
	  subj <- subjs[s]
	  for (r in 1:length(runs)) {
	  	run <- runs[r]
	 	d <- data[data$subj==subj & data$run==run,]
	    p <- ggplot(aes(x=lag, y=pe, color=run), data=d) + facet_grid(region ~ hemisphere, scales='free_y')
	    p <- p + geom_line() + opts(strip.text.y=theme_text()) + opts(title=sprintf('%s %s', subj, run))
	    p <- p + theme_bare
	    print(p, vp=vplayout(s, r))
  		}
	}
	dev.off()
}


plot.multiple.firs <- function(data, output_dir) {
	# for each subject x run, plot a line connecting the mean of each condition
	runs <- unique(data$run)
	subjs <- unique(data$subj)
	
	# this grid code is from ggplot2 book pg.154
	pdf(paste(output_dir, 'fir_mults.pdf', sep='/'), height=2*length(subjs), width=4*length(runs))
	grid.newpage()
	pushViewport(viewport(layout=grid.layout(length(subjs), length(runs))))
	vplayout <- function(row, col)
		viewport(layout.pos.row=row, layout.pos.col=col)
	
	for (s in 1:length(subjs)) {
	  subj <- subjs[s]
	  for (r in 1:length(runs)) {
	  	run <- runs[r]
	 	d <- data[data$subj==subj & data$run==run,]
	    p <- ggplot(aes(x=lag, y=pe, color=run), data=d) + facet_grid(region ~ hemisphere, scales='free_y')
	    p <- p + geom_line() + opts(strip.text.y=theme_text()) + opts(title=sprintf('%s %s', subj, run))
	    print(p, vp=vplayout(s, r))
  		}
	}
	dev.off()
}

plot.nonzero.lag.pes <- function(data, lags, output_dir) {
  N <- length(unique(data$subj))
  
  # for each region, l holds only the data from lags that were in lags$region
  l <- ddply(data, 'region', function(X) subset(X, lag %in% lags[[X$region[1]]]))

	# we compute the mean and standard error for each subject x hemisphere x region for the given lags, by taking the mean across trials for each of those, centering those means for each subject to make them comparable, and taking the sds across subjects divided by sqrt(N) to get the se
	across.lag.means <- ddply(l, c('subj', 'run', 'hemisphere', 'region'), summarise, pe=mean(pe))
	centered <- ddply(across.lag.means, c('subj', 'hemisphere', 'region'), function(X) data.frame(run=X$run, pe=center(X$pe)))
	ses <- ddply(centered, c('run', 'hemisphere', 'region'), function(X) data.frame(se=sd(X$pe)/sqrt(N)))
	means <- ddply(l, c('run', 'hemisphere', 'region'), summarise, mean=mean(pe))
	summ <- cbind(ses, mean=means$mean)

  p <- ggplot(data=summ, aes(x=run)) + facet_grid(hemisphere ~ region)
  p <- p + geom_bar(aes(y=mean, fill=run), color='black')
  p <- p + geom_errorbar(aes(y=mean, ymin=mean-se, ymax=mean+se), color='black', width=0.3)
  #p <- p + coord_cartesian(ylim=c(-.25,1.25))
  ggsave(paste(output_dir, 'averaged_PEs.pdf', sep='/'), plot=p, width=9, height=6)
}


plot.nonzero.lag.pes.collapsed.across.hemisphere <- function(data, lags, output_dir) {
  N <- length(unique(data$subj))

  # for each region, l holds only the data from lags that were in lags$region
  l <- ddply(data, 'region', function(X) subset(X, lag %in% lags[[X$region[1]]]))

	# we compute the mean and standard error for each subject x region for the given lags, by taking the mean across trials for each of those, centering those means for each subject to make them comparable, and taking the sds across subjects divided by sqrt(N) to get the se
	across.lag.means <- ddply(l, c('subj', 'run', 'region'), summarise, pe=mean(pe))
	centered <- ddply(across.lag.means, c('subj', 'region'), function(X) data.frame(run=X$run, 	pe=center(X$pe)))
	ses <- ddply(centered, c('run', 'region'), function(X) data.frame(se=sd(X$pe)/sqrt(N)))
	means <- ddply(l, c('run', 'region'), summarise, mean=mean(pe))
	summ <- cbind(ses, mean=means$mean)

  p <- ggplot(data=summ, aes(x=run)) + facet_grid(region ~ .)
  p <- p + geom_bar(aes(y=mean, fill=run), color='black')
  p <- p + geom_errorbar(aes(y=mean, ymin=mean-se, ymax=mean+se), color='black', width=0.3)
  #p <- p + coord_cartesian(ylim=c(-.25,1.25))
  ggsave(paste(output_dir, 'averaged_PEs_hemi_averaged.pdf', sep='/'), plot=p, width=9, height=6)
}

# runs hemisphere x run within-subjects ANOVA:

test.for.hemisphere.interaction <- function(data, output_dir) {
  d_ply(data, 'region', function(data) {  
    region=unique(data$region)[1]
    a <- aov(pe ~ (hemisphere * run) + Error(subj/(hemisphere * run)), data=data)
    xt <- xtable(a)
    print(xt, type='latex', file=sprintf('%s/%s_hemisphere_anova.tex', output_dir, region))
    print(xt, type='html', file=sprintf('%s/%s_hemisphere_anova.html', output_dir, region))
  })
}

find.nonzero.lags <- function(data) {
  THRESHOLD <- 0.05

  # average within subject x lag, then t-test each lag against 0
  means <- ddply(data, c('lag', 'subj', 'region'), summarize, pe=mean(pe))
  pvals <- ddply(means, c('lag', 'region'), summarize, p.value=t.test(pe, mu=0, alternative='greater')$p.value)
  lags <- dlply(pvals, 'region', function(X) X$lag[X$p.value < THRESHOLD])
  lags
}


# concatenate data from each subject into one big data frame
group_data <- data.frame()
for (subj in subjects) {
  load(sprintf('subjects/%s/%s/roi_results.Rdat', subj, SUBJ_ROI_DIR))
  group_data <- rbind(group_data, data)
  rm(data)
}

save(group_data, file=sprintf('%s/roi_results.Rdat', ROI_RESULTS_DIR))
write.csv(group_data, file=sprintf('%s/roi_results.csv', ROI_RESULTS_DIR))

plot.mean.firs(group_data, ROI_RESULTS_DIR)
plot.small.multiple.firs(group_data, ROI_RESULTS_DIR)
plot.multiple.firs(group_data, ROI_RESULTS_DIR)

nonzero.lags <- find.nonzero.lags(group_data) 
plot.nonzero.lag.pes(group_data, nonzero.lags, ROI_RESULTS_DIR)
plot.nonzero.lag.pes.collapsed.across.hemisphere(group_data, nonzero.lags, ROI_RESULTS_DIR)
test.for.hemisphere.interaction(group_data, ROI_RESULTS_DIR)
plot.mean.firs.collapsed.across.hemisphere(group_data, ROI_RESULTS_DIR)