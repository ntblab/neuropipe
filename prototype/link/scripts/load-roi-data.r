#!/usr/csbmb/pkg/R/bin/R

args <- commandArgs(TRUE)
subj = args[1]
roi_data_dir = args[2]
FIR_LAGS = args[3]
rois_info = args[4:length(args)]

OUTPUT_FILE = sprintf('%s/roi_results.Rdat', roi_data_dir)

FIR_LAGS <- eval(parse(text=FIR_LAGS))

#save(FIR_LAGS, file=OUTPUT_FILE)

csv_colnames = c('coords', sprintf('lag%d', FIR_LAGS), 'junk' )
region_names = c(rois_info)

rois <- data.frame()
for (roi in 1:length(region_names)) {
	list<-(strsplit(region_names,''))
	new_roi<-as.matrix(list)[[roi]][2:length(list)[1]]	
	new_roi<-paste(new_roi,collapse="")
	rois <-c(rois, new_roi) 
	}
rois<-unlist(rois)

hemispheres <- data.frame()
for (roi in 1:length(region_names)) {
	hemispheres<- c(hemispheres, as.matrix(strsplit(region_names,''))[[roi]][1])
	}
hemispheres<-unlist(hemispheres)



# this bunch of code will dive through a directory hierarchy to produce a data
# frame with 1 row for each lag x condition x region of this subject.
data = data.frame()
excluded_rois = data.frame()

run_dirs = dir( roi_data_dir )

for (run in run_dirs) {
  run_path = sprintf('%s/%s', roi_data_dir, run)
  results_csvs = dir( run_path )

  for (csv in results_csvs) {
    print( sprintf('loading %s  %s  %s', subj, run, csv) )

    csv_path = sprintf('%s/%s', run_path, csv)
    csv_data = read.csv(csv_path, header=TRUE, col.names=csv_colnames)

    # supplement the csv data with subject, run, region, and condition info
    region = rois
    hemisphere = hemispheres
    condition = strsplit(csv, '\\.')[[1]][1]
    supplemented_csv_data <- cbind(subj, run, region, hemisphere, condition, csv_data)
	 
    stacked_data <- do.call(rbind, apply( supplemented_csv_data, 1, function(row) {
      subj = row['subj']
      region = row['region']
      hemisphere = row['hemisphere']
      run = row['run']
      cond = row['condition']
      lag_pes = as.numeric( row[ sprintf('lag%d',FIR_LAGS) ] )
      d <- data.frame( lag=FIR_LAGS, pe=lag_pes, region=region, hemisphere=hemisphere, condition=condition, subj=subj, run=run )
      d
    }) )

    data <- rbind(data, stacked_data)
  }
}

included_data = subset(data, data[,2]!= 0) 

save(included_data,data, file=OUTPUT_FILE)

