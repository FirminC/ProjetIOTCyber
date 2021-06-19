function updateTruckToVisualAlert(element){
    var truckToUpdate = JSON.parse(element);
    if(!document.getElementById("stolen_trucks")){
        return
    }
    var list = document.getElementsByClassName("truck");
    var HTMLElement = null;
    for (let i = 0; i < list.length; i++) {
        if(list[i].getAttribute("data-truck_hex") == truckToUpdate.hex_identifier){
            HTMLElement = list[i];
            console.log(HTMLElement)
        }
    }
    if(!HTMLElement && truckToUpdate.lastTruckMapInfo.is_stolen){                               //add to list
        console.log("adding");
        var div = document.createElement("div");
        div.className = "truck";
        div.setAttribute("data-truck_hex", truckToUpdate.hex_identifier)
        var p = generatePElement(truckToUpdate);
        div.appendChild(p);
        document.getElementById("stolen_trucks").appendChild(div);
    }else
    if(HTMLElement && truckToUpdate.lastTruckMapInfo && truckToUpdate.lastTruckMapInfo.is_stolen){                                //update HTML Element
        console.log("update");
        HTMLElement.innerHTML = null;
        var p = generatePElement(truckToUpdate);
        HTMLElement.appendChild(p);
    }
    if(HTMLElement && (truckToUpdate.delete || (truckToUpdate.lastTruckMapInfo && !truckToUpdate.lastTruckMapInfo.is_stolen))){     //remove HTML Element from list
        console.log("remove");
        HTMLElement.remove();
    }
}

function generatePElement(truck){
    var p = document.createElement("p");
    var t = document.createTextNode("Nom du camion : "+ truck.name);
    p.appendChild(t);
    var br = document.createElement("br");
    p.appendChild(br);
    t = document.createTextNode("Niveau de carburant : " + truck.lastTruckMapInfo.fuel_level + "%");
    p.appendChild(t);
    br = document.createElement("br");
    p.appendChild(br);
    t = document.createTextNode("Pour plus d'inforation, cliquer ");
    p.appendChild(t);
    a = document.createElement("a");
    a.setAttribute('href', "/trucks/"+truck.id);
    t = document.createTextNode("ici");
    a.appendChild(t);
    p.appendChild(a);
    t = document.createTextNode(".");
    p.appendChild(t);
    return p;
}