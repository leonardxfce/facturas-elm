port module Ports exposing (downloadFile, fileContentReceived, selectFile, triggerPrint)


port triggerPrint : () -> Cmd msg


port downloadFile : { name : String, content : String } -> Cmd msg


port selectFile : () -> Cmd msg


port fileContentReceived : (String -> msg) -> Sub msg
