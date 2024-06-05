#' install the R Kernel
#'
#' @export
install <- function(){
    installspec()
}


#' @describeIn install Install the R Kernel spec
#'
#' @importFrom jsonlite fromJSON toJSON
#' @param user Logical, whether to install the kernel in the user's home directory
#' @param sys_prefix Logical, whether to install the kernel in the python sys prefix
#' @param prefix NULL or a character string with a path prefix
#' @export
# The following is adapted from IRKernel/R/installspec.r
installspec <- function(name="rkernel",display_name="RKernel",user=FALSE,sys_prefix=TRUE,prefix=NULL,single_blas=FALSE,jupyter_cmd="jupyter"){
   kernelspec_srcdir <- system.file("kernelspec",package="RKernel")
   tmp_dir <- tempfile()
   dir.create(tmp_dir)
   file.copy(kernelspec_srcdir,tmp_dir,recursive=TRUE)
   
   json_infile <- file.path(tmp_dir,"kernelspec","RKernel.json")
   json_outfile <- file.path(tmp_dir,"kernelspec","kernel.json")
   kernelspec <- fromJSON(json_infile)
   # Put the absolute path of the current interpreter
   kernelspec$argv[[1]] <- file.path(R.home("bin"),"R")
   kernelspec$display_name = paste(
       "R (",
       if(nchar(display_name)) display_name else "RKernel",
       ")",
       sep=""
   )
   write(toJSON(kernelspec,pretty=TRUE,auto_unbox=TRUE),
         file=json_outfile)
   unlink(json_infile)
   jupyter_call <- c(
       jupyter_cmd,
       "kernelspec",
       "install",
       "--replace",
       "--name",
       if(nchar(name)) name else "rkernel",
       if(user) "--user" else NULL,
       if(sys_prefix) "--sys-prefix" else NULL,
       if(length(prefix)) paste0("--prefix=",prefix),
       file.path(tmp_dir,"kernelspec")
   )
   exit_code <- system2(jupyter_call)

   if(single_blas){ 
       json_infile <- file.path(tmp_dir,"kernelspec","RKernel1blas.json")
       json_outfile <- file.path(tmp_dir,"kernelspec","kernel.json")
       kernelspec <- fromJSON(json_infile)
       # Put the absolute path of the current interpreter
       kernelspec$argv[[1]] <- file.path(R.home("bin"),"R")
       kernelspec$display_name = paste(
           "R (",
           if(nchar(display_name)) display_name else "RKernel",
           ", single-threaded openblas)",
           sep=""
       )
       write(toJSON(kernelspec,pretty=TRUE,auto_unbox=TRUE),
             file=json_outfile)
       unlink(json_infile)
       jupyter_call <- c(
           jupyter_cmd,
           "kernelspec",
           "install",
           "--replace",
           "--name",
           if(nchar(name)) paste(name, "1blas", sep="") else "rkernel1blas",
           if(user) "--user" else NULL,
           if(sys_prefix) "--sys-prefix" else NULL,
           if(length(prefix)) paste0("--prefix=",prefix),
           file.path(tmp_dir,"kernelspec")
       )
       exit_code <- system2(jupyter_call)
   }
   unlink(tmp_dir,recursive=TRUE)
   invisible(exit_code)
}
