#!/usr/bin/env lua

stanze = {
};

azioni = {}

azioni.vai = function (where) 
    go_to_room(where)
end

azioni.guarda = function () 
    guarda_oggetti(current_room.oggetti)
    guarda_uscite()
end

azioni.prendi = function (oggetto)
    prendi_oggetto(oggetto)
end

azioni.osserva = function (oggetto)
    osserva_oggetto(oggetto)
end

azioni.inventario = function ()
    print("INVENTARIO")
    guarda_oggetti(inventory)
end

azioni.dove = function() 
    stampa_posizione()
end

function string:split(delimiter)
    local result = {}
    for match in self:gmatch("([^" .. delimiter .. "]+)") do
        table.insert(result, match)
    end
    return result
end

function make_room(name, desc, uscite, oggetti)
    room = {}
    room.name = name
    room.desc = desc
    room.uscite = uscite
    room.oggetti = oggetti
    return room
end

function go_to_room(argomento) 
    print("Sono in " .. current_room.name)
    print("Dovrei andare in una stanza")
    if argomento then 
        if  current_room.uscite[argomento] then
            destinazione = current_room.uscite[argomento]
            current_room = stanze[destinazione]
            print("Ti trovi in " .. current_room.desc)
        else
            print("Non conosco questa stanza")
        end
    else
        print("Dimmi dove devo andare")
    end
end

function guarda_uscite()
    io.write("Uscite: ")
    for key, value in pairs(current_room.uscite) do
        io.write(tostring(key) .. " ")
    end
    print()
end

function stampa_posizione()
    print("Ti trovi in " .. current_room.name)
end

function count_items(tab)
    if not tab then
        return 0
    end
    count = 0
    for key, value in pairs(tab) do
        count = count + 1
    end
    return count
end

function guarda_oggetti(tabella)
    n_ogg = count_items(tabella)
    print("Vedo " .. n_ogg .. " oggetti")
    if n_ogg > 0 then
        for key, value in pairs(tabella) do
            print("Oggetto: " .. tostring(key))
        end
    end
end

function osserva_oggetto(oggetto)
     if current_room.oggetti[oggetto] then 
         oggetto = current_room.oggetti[oggetto] -- facciamo shadowing
         print("Guardiamo da vicino...")
         print(oggetto.desc)
     else
         print("Che? No, non c'è niente del genere in questa stanza")
     end
end

function prendi_oggetto(oggetto)
    if not current_room.oggetti[oggetto] then
        print("Non posso prendere " .. oggetto .. ". non esiste")
    else
        inventory[oggetto] = current_room.oggetti[oggetto]
        current_room.oggetti[oggetto] = nil
    end
end

-- TODO - Sezione in costruzione
function make_personaggio(nome, tipo, statistiche, ruolo, pos)
    --- ruolo: npc, mob
    --- statistiche: le varie statistiche: atk, def, mana, res etc etc, solo se non npc
    --- pos: la posizione in coordinate x, y - per il futuro
    personaggio = {}
    personaggio.nome = nome
    personaggio.tipo = tipo
    personaggio.stats = statistiche
    personaggio.ruolo = ruolo
    return personaggio
end

-- stampa il contenuto e la struttura della tabella
-- tiene conto anche delle sottotabelle
-- perché sì
function show_table(tabella, indent) 
    indent = indent or 0
    local cosa = (indent > 0) and "sottotabella" or "tabella"
    local pad = string.rep(" ", indent)
    if cosa == "tabella" then
        print("La " .. cosa .. " contiene: ");
        print("{");
    else
        print(pad .. "{");
    end
    for key, value in pairs(tabella) do
        if type(value) == "table" then
            print(pad .. pad .. " " .. tostring(key) .. ":")
            show_table(value, indent + 4)
        else
            print(pad .. pad .. " " .. tostring(key) .. " : " ..tostring(value))
        end
    end
      print(pad .. "}" )
end

function main() 
    inventory = {}
    chiave_segreta = { desc = "Una chiave per la porta segreta" }
    mazza = { desc = "Una mazza chiodata" }
    spada = { desc = "La spada de foco" }
    segreta_uscite = {nord= 'armeria', est = 'giardino'}
    armeria_uscite = { sud = "segreta" }
    giardino_uscite = { ovest = "segreta" } 
    segreta_oggetti = { chiave = chiave_segreta , mazza = mazza , spada = spada }
    atrio_uscite = { ovest = 'armeria' }

    -- creo le stanze
    stanze.segreta = make_room('segreta', 'Una stanza segreta', segreta_uscite, segreta_oggetti)
    stanze.atrio = make_room('atrio', 'Un atrio nella penombra', atrio_uscite, {})
    stanze.armeria = make_room('armeria', 'Armeria', armeria_uscite, {})
    stanze.giardino = make_room('giardino', 'Il Giardino', giardino_uscite, {})
    current_room = stanze.giardino


    while true do
        io.write("[".. current_room.name .. "] Azione: ")
        valore = io.read()
        local argomenti = valore:split(" ")
        if argomenti[1] == "esci" then 
            break
        end

        if azioni[argomenti[1]] then
            azioni[argomenti[1]](argomenti[2] or nil)
        else
            print("Non so come fare")
        end

    end
end

while true do
    main()
    io.write('Vuoi giocare ancora? ')
    risposta = io.read()
    if risposta == 'no' then
        break
    end

end