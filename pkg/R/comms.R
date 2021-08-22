CommDispatcher <- R6Class("CommDispatcher",
    
    public=list(

        initialize = function(kernel){
            private$kernel <- kernel
        },

        startup = function(...){
            pos <- match("RKernel",search())
            assign("comm.add_handlers",self$add_handlers,pos=pos)
            assign("comm.remove_handlers",self$remove_handlers,pos=pos)
            assign("comm.new",self$new_comm,pos=pos)
            assign("comm.getall",self$get_comms,pos=pos)
        },

        add_handlers = function(target_name,handlers){
            private$targets[[target_name]] <- handlers
        },
        remove_handlers = function(target_name) {
            private$targets[[target_name]] <- NULL
        },
        get_comms = function(target_name=NULL){
            comms <- list()
            for(c in private$comms){
                if(!length(target_name || target_name %in% names(private$targets)))
                    comms[c$id] <- list(target_name=c$target_name)
            }
            return(comms)
        },
        new_comm = function(target_name,data){
            if(target_name %in% names(private$targets)){
                id <- UUIDgenerate()
                handlers <- private$targets[[target_name]]
                comm <- Comm$new(target_name,id,self,handlers)
                comm$handle_open(data)
                return(comm)
            }
            else return(NULL)
        },
        handle_open = function(target_name,id,data){
            if(target_name %in% names(private$targets)){
                handlers <- private$targets[[target_name]]
                comm <- Comm$new(target_name,id,self,handlers)
                comm$handle_open(data)
                private$comms <- append(private$comms,comm)
            }
            else {
                self$send_close(id,target_name)
            }
        },
        handle_close = function(id,data){
            comm <- private$comms[id]
            comm$handle_close(data)
        },
        handle_msg = function(id,data){
            comm <- private$comms[id]
            comm$handle_msg(data)
        },
        send = function(id,data){
            private$kernel$comm_send(id,data)  
        },
        send_open = function(id,data){
            private$kernel$comm_send_open(id,data)  
        },
        send_close = function(id,target_name){
            private$kernel$comm_send_close(id,data)  
        }
    ),
    
    private = list(
        kernel  = list(),
        targets = list(),
        comms   = list()
    )
)

Comm <- R6Class("Comm",

    public = list(
        
        initialize = function(target_name,id,dispatcher,handlers){
            private$target_name <- target_name
            private$id <- id
            private$dispatcher <- dispatcher
            self$set_handler(handlers)
        },

        open = function(data){
            id <- private$id
            private$dispatcher$send_open(id,data)
        },
        send = function(data){
            id <- private$id
            private$dispatcher$send(id,data)
        },
        close = function(data){
            id <- private$id
            private$dispatcher$send_close(id,data)
        },
        handle_open = list(),
        handle_msg = list(),
        handle_close = list(),
        set_handlers = function(handlers){
            if(is.function(handlers$open))
                self$handle_open <- handlers$open
            else
                self$handle_open <- function(...) NULL
            if(is.function(handlers$msg))
                self$handle_msg <- handlers$msg
            else
                self$handle_msg <- function(...) NULL
            if(is.function(handlers$close))
                self$handle_close <- handlers$close
            else
                self$handle_close <- function(...) NULL
        }
    ),
    
    private = list(
        id = character(0),
        target_name = character(0),
        dispatcher = list()
    )
)