module Money exposing (Cents, centsToDecimalString, formatCents, parseCents)


type alias Cents =
    Int


{-| Parse a human string like "12", "12.5", "12.50" into cents.
Rejects negatives and non-numeric input.
-}
parseCents : String -> Maybe Cents
parseCents raw =
    let
        s =
            String.trim raw
    in
    if String.startsWith "-" s then
        Nothing

    else
        case String.split "." s of
            [ whole ] ->
                String.toInt whole |> Maybe.map (\w -> w * 100)

            [ whole, frac ] ->
                let
                    w =
                        String.toInt whole

                    padded =
                        String.left 2 frac |> String.padRight 2 '0'

                    f =
                        String.toInt padded
                in
                Maybe.map2 (\ww ff -> ww * 100 + ff) w f

            _ ->
                Nothing


{-| Format cents as "$X.YY" for display.
-}
formatCents : Cents -> String
formatCents cents =
    "$" ++ centsToDecimalString cents


{-| Render cents as "X.YY" without currency marker — for CSV and edit forms.
-}
centsToDecimalString : Cents -> String
centsToDecimalString cents =
    let
        whole =
            cents // 100

        frac =
            remainderBy 100 cents
    in
    String.fromInt whole ++ "." ++ String.padLeft 2 '0' (String.fromInt frac)
