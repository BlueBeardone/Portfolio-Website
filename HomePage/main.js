function ChangeDescription(Choice) {
    var p = document.querySelector(".shortDescription");
    var text = 4;

    switch(Choice) {
        case 0: text = "I am skilled programmer with: "+
                        "<br>"+
                        "<b>Javascript, C#, SQL, HTML, CSS</b>" ;
        break;
        case 1: text = "With a strong foundation in HTML, CSS, JavaScript, C#, and Unity, I have successfully developed numerous software projects, particularly excelling in game development through my active participation in multiple game jams."+ 
                        "<br>" +
                       "My technical expertise extends to database management, where I have proficiently handled MySQL, SQL, and Microsoft Access. One notable aspect of my work experience includes data and database management for a political party, where I demonstrated my ability to gather, organize, and analyze complex datasets. My diverse skill set and hands-on experience underscore my capability to deliver high-quality solutions in dynamic and challenging environments.";
        break;
        case 2: text = "As a highly skilled software developer, I specialize in HTML, CSS, JavaScript, C#, Unity, MySQL, SQL, and Microsoft Access. With a strong ability to write efficient, clean code, I have a track record of successfully participating in multiple game jams, showcasing my ability to deliver high-quality projects under tight deadlines. My experience extends to data and database management, where I gathered, organized, and analyzed data for a political party, demonstrating my proficiency in managing complex datasets and ensuring data integrity. I am passionate about continuous learning and am always eager to take on new challenges that further develop my technical skills and contribute to impactful projects.";
        break;
        default: text = "Welp";
        break;
    }

    if (text != null) {
        p.innerHTML = text;
        ButtonsClicked(Choice);
    }

    
}

function ButtonsClicked(Choice){
    var p = document.querySelector(".MainBoxchange");

    var text = "";

    

    switch (Choice) {
        case 0: text = "<li><button class='MainBoxchangeListItems' onclick='ChangeDescription(0)' style='background-color: blue; color: azure;'>About</button></li>" +
            "<li><button class='MainBoxchangeListItems' onclick='ChangeDescription(1)'>Skills</button></li>" +
            "<li><button class='MainBoxchangeListItems' onclick='ChangeDescription(2)'>History</button></li>";
            
            break;
        case 1: text = "<li><button class='MainBoxchangeListItems' onclick='ChangeDescription(0)'>About</button></li>" +
        "<li><button class='MainBoxchangeListItems' onclick='ChangeDescription(1)' style='background-color: blue; color: azure;'>Skills</button></li>" +
        "<li><button class='MainBoxchangeListItems' onclick='ChangeDescription(2)'>History</button></li>";
            
            break;
        case 2: text = "<li><button class='MainBoxchangeListItems' onclick='ChangeDescription(0)'>About</button></li>" +
        "<li><button class='MainBoxchangeListItems' onclick='ChangeDescription(1)'>Skills</button></li>" +
        "<li><button class='MainBoxchangeListItems' onclick='ChangeDescription(2)' style='background-color: blue; color: azure;'>History</button></li>";
            
            break;
    
        default:
            break;
    }

    p.innerHTML = text;
}
ChangeDescription(0);

