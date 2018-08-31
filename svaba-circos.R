library(BioCircos)
library(VariantAnnotation)
library(GenomicRanges)
library(ggbio)
library(RCircos)
library(htmlwidgets)
library(webshot)
library(optparse)

option_list = list(
  make_option(c("-i", "--input"),  type = "character", default = NULL,  help = "Path to VCF file"),
  make_option(c("-o", "--output"), type = "character", default = "circos.html",  help = "Output basename of html to write the graph")
)

parseobj = OptionParser(option_list=option_list)
opt = parse_args(parseobj)

if (is.null(opt$input))
  stop(print_help(parseobj))



vcf <- readVcf(opt$input,"hg38")

chrGR <- as(seqinfo(vcf), "GRanges")
idx <- GenomicRanges:::get_out_of_bound_index(chrGR)
if (length(idx) != 0L)
  chrGR <- chrGR[-idx]
# Chromosomes on which the points should be displayed
points_chromosomes = gsub("^.*\\.","",as.character(seqnames(chrGR)))

# Coordinates on which the points should be displayed
points_coordinates = end(ranges(chrGR))
# Values associated with each point, used as radial coordinate 
#   on a scale going to minRadius for the lowest value to maxRadius for the highest valueq
points_values = 0:(length(points_coordinates)-1)

tracklist = BioCircosSNPTrack('mySNPTrack', points_chromosomes, points_coordinates, 
                              points_values, colors = c( "darkblue"), minRadius = 0.4, maxRadius = 0.8)

# Background are always placed below other tracks
tracklist = tracklist + BioCircosBackgroundTrack("myBackgroundTrack", 
                                                 minRadius = 0.4, maxRadius = 0.8,
                                                 borderColors = "#AAAAAA", borderSize = 0.6, fillColors = "#B3E6FF")  
tracklist = tracklist + BioCircosTextTrack("testText", '12323 germline SV', weight = "lighter", 
                                     x = - 0.4, y =  -0.87)
widg = BioCircos(tracklist, genomeFillColor = "PuOr",
          chrPad = 0.05, displayGenomeBorder = FALSE, yChr =  FALSE,
          genomeTicksDisplay = FALSE,  genomeLabelTextSize = 18, genomeLabelDy = 0)


saveWidget(widg,file = opt$output)
