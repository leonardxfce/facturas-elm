module Main exposing (main)

import Browser
import Html exposing (Html, div, h1, li, text, ul)
import Html.Attributes exposing (style)


-- MODEL


type alias Invoice =
    { id : Int
    , client : String
    , amount : Float
    }


type alias Model =
    { invoices : List Invoice
    }


initialModel : Model
initialModel =
    { invoices =
        [ { id = 1, client = "Juan Perez", amount = 150.5 }
        , { id = 2, client = "Maria Garcia", amount = 200.0 }
        , { id = 3, client = "Pedro Lopez", amount = 75.25 }
        ]
    }



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> Model
update msg model =
    case msg of
        NoOp ->
            model



-- VIEW


view : Model -> Html Msg
view model =
    div [ style "padding" "20px", style "font-family" "sans-serif" ]
        [ h1 [] [ text "Mis Facturas" ]
        , ul [] (List.map viewInvoice model.invoices)
        ]


viewInvoice : Invoice -> Html Msg
viewInvoice invoice =
    li [ style "margin-bottom" "10px" ]
        [ div [ style "font-weight" "bold" ] [ text invoice.client ]
        , div [] [ text ("Monto: $" ++ String.fromFloat invoice.amount) ]
        , div [ style "color" "#666", style "font-size" "0.8em" ] [ text ("ID: " ++ String.fromInt invoice.id) ]
        ]



-- MAIN


main : Program () Model Msg
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update
        }
