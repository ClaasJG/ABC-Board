ExportMode="ModelBoard"; //["ModelBoard", "Cut"]

/* [Font] */
// The logical name of the font to use
FontName="Monospace:style=Bold";
// Approximate ascent (height above the baseline) in mm for a single character.
CharSize=55; //[::non-negative integer]
// The width of the box used to center a character in mm.
CharBoxWidth=50;
// The height of the box used to center a character in mm.
CharBoxHeight=50;
// The distance between the boxes used to center charaters in teh horizontal axis in mm.
CharBoxPaddingWidth=15;
// The distance between the boxes used to center charaters in teh vertical axis in mm.
CharBoxPaddingHeight=15;


/* [Board] */
// Characters per line
Lines=[
    "ABCDEFG",
    "HIJKLMN",
    "OPQRSTU",
    "VWXYZ"
];
// Thickness of the used board material.
Thickness=5.2;
// Border around the characters.
BoardPadding=10;
// The rounding radius used for the board corners.
CornerRounding=25;

/* [Handle] */
// Add a handle to the left side.
LeftHandle=true;
// Add a handle to the right side.
RightHandle=false;
// Add a handle to the upper side.
UpperHandle=false;
// Add a handle to the lower side.
LowerHandle=false;

// The width of the bridge used for the handle in mm.
GripSize=35;
// The width of the hole used for the handle in mm.
FingerSpace=35;
// The length of the handle in mm.
HandleLength=90;
// Rounding radius used for the handle hole.
HandleRounding=15;

/////// Start building
innerWidth = max([for(line = Lines)
    len(line)*(CharBoxWidth+CharBoxPaddingWidth)+CharBoxPaddingWidth
]);
innerHeight = len(Lines)*(CharBoxHeight+CharBoxPaddingHeight)+CharBoxPaddingHeight;

if(ExportMode == "ModelBoard"){
    difference(){
        base_board();
        alphabet_text();
    }
} else if(ExportMode == "Cut"){
    projection(cut=false){
        difference(){
            base_board();
            alphabet_text();
        }
    }
} else {
    echo (str("ERROR: Unknown Mode: ", ExportMode));
}

module base_board() {
    borderPaddingLeft = LeftHandle
        ? max(BoardPadding , FingerSpace + GripSize) : BoardPadding;
    borderPaddingRight = RightHandle
        ? max(BoardPadding , FingerSpace + GripSize) : BoardPadding;
    borderPaddingUp = UpperHandle
        ? max(BoardPadding , FingerSpace + GripSize) : BoardPadding;
    borderPaddingDown = LowerHandle
        ? max(BoardPadding , FingerSpace + GripSize) : BoardPadding;
    
    bordWidth = innerWidth+borderPaddingLeft+borderPaddingRight;
    boardHeight = innerHeight+borderPaddingUp+borderPaddingDown;
    
    difference(){
        translate([-borderPaddingLeft, -borderPaddingDown]){
            rounded_rect(bordWidth, boardHeight, Thickness, CornerRounding);
        }
        translate([-borderPaddingLeft,(innerHeight-HandleLength)/2,0]){
            if(LeftHandle) {
                translate([GripSize,0,-1])
               rounded_rect(FingerSpace, HandleLength, Thickness+2, HandleRounding); 
            }
            if(RightHandle) {
                translate([bordWidth-GripSize-FingerSpace,0,-1])
               rounded_rect(FingerSpace, HandleLength, Thickness+2, HandleRounding); 
            }
        }
        translate([(innerWidth-HandleLength)/2,-borderPaddingDown,0]){
            if(UpperHandle) {
               translate([0,boardHeight-GripSize-FingerSpace,-1])
               rounded_rect(HandleLength, FingerSpace, Thickness+2, HandleRounding); 
            }
            if(LowerHandle) {
               translate([0,GripSize,-1])
               rounded_rect(HandleLength, FingerSpace, Thickness+2, HandleRounding); 
            }
        }
    }
}

module alphabet_text(tolerance = 1) {
    translate([CharBoxWidth/2, CharBoxHeight/2, -tolerance])
    translate([CharBoxPaddingWidth, CharBoxPaddingHeight, 0])
    for(y = [0:len(Lines)-1]){
        line = Lines[len(Lines) - 1 - y];
        for(x = [0:len(line)-1]) {
            translate([x * CharBoxWidth, y * CharBoxHeight, 0])
            translate([x * CharBoxPaddingWidth, y * CharBoxPaddingHeight, 0])
            linear_extrude(height = Thickness + tolerance * 2)
            text(
                text = str(line[x]),
                font = FontName,
                size = CharSize,
                valign = "center",
                halign = "center"
            );
        }
    }
}

module rounded_rect(w, h, d, r) {
    difference(){
        cube(size=[w, h, d]);
        translate([0,0,-1]){fillet(r, d+2);};
        translate([w,0,-1]){rotate([0,0,90])fillet(r, d+2);};
        translate([w,h,-1]){rotate([0,0,180])fillet(r, d+2);};
        translate([0,h,-1]){rotate([0,0,270])fillet(r, d+2);};
    } 
}

module fillet(r, h) {
    translate([r / 2, r / 2, h/2])
    difference(){
        cube([r + 0.01, r + 0.01, h], center = true);
        translate([r/2, r/2, 0])
            cylinder(r = r, h = h + 1, center = true);
    }
}