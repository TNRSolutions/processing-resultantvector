
Handle[] handles;
PFont f;

void setup() {
  size(1200, 800);
  
  // Create the font
  printArray(PFont.list());
  f = createFont("AgencyFB-Reg-48.vlw", 24);
  textFont(f);
  
  // Set up the individual vectors
  int num = 4; //height/15;
  handles = new Handle[num];

  //for (int i = 0; i < handles.length; i++) {
    handles[0] = new Handle(width/2, height/2, 20,5, handles, "A");
    handles[1] = new Handle(width/2, height/2, -45,20, handles, "B");
    handles[2] = new Handle(width/2, height/2, -45,-20, handles, "C");
    
    handles[3] = new Handle(width/2, height/2, handles, "R");
    


  //}
}

void draw() {
  background(200);
  
  for (int i = 0; i < handles.length; i++) {
    handles[i].update();
    handles[i].display();
    updateStats(handles[i], i, handles.length);
  }
  
}

//
//  Update the display of vector mags and directions
//
void updateStats(Handle vector, int index, int vectorCount)
{
  text(vector.getName(), 500, 100 +(30*index));
  text(vector.getVector().mag(), 520, 100 +(30*index));

  PVector vertical = new PVector(0,-1);
  float a = PVector.angleBetween(vertical, vector.getVector());
  text(degrees(a), 660, 100 +(30*index));
}

void mouseReleased()  {
  for (int i = 0; i < handles.length; i++) {
    handles[i].releaseEvent();
  }
}


class Handle {
  
  int x, y; // root location
  //int stretch;  // length of the line
  PVector vec = new PVector(0, 0);  // A vector that describes this instance
  int size = 20;  // size of the box
  
  String _name = ""; // Name this vector
  
  // Interaction with this vector
  boolean over;
  boolean press;
  boolean locked = false;
  boolean otherslocked = false;
  Handle[] others;
  boolean isResultant = false;
  
  // Constructor
  Handle(int rootx, int rooty, int vx, int vy, Handle[] o, String name) {
    x = rootx;
    y = rooty;
    vec.set(vx, vy); // set the vector 
    _name = name;

    others = o;
  }
  
  //Constructor
   Handle(int rootx, int rooty, PVector pv, Handle[] o, String name) {
    x = rootx;
    y = rooty;
    vec.set(pv); // set the vector 
    _name = name;

    others = o;
  }
  
  //Constructor for the resultant vector
   Handle(int rootx, int rooty,  Handle[] o, String name) {
    x = rootx;
    y = rooty;
    vec = new PVector(0,0); // initialise the vector 
    _name = name;
    
    isResultant = true;
    others = o;
  }  
  
  String getName()
  {
      return _name;  
  }
  
  
  PVector getVector(){
   return vec; 
  }
  
  PVector sum(PVector v)
  {
     return PVector.add(vec,v); 
  }
  
  void update() {
    for (int i=0; i<others.length; i++) {
      if (others[i].locked == true) {
        otherslocked = true;
        break;
      } else {
        otherslocked = false;
      }  
    }
    
    if (otherslocked == false) {
      overEvent();
      pressEvent();
    }
    
    if (press) {
      //stretch = lock(mouseX-width/2-size/2, 0, width/2-size-1);
      vec = new PVector(mouseX,mouseY);
      PVector center = new PVector(x, y);
      vec.sub(center);
    }
    
    if(isResultant)
    {
      PVector resultantVector = new PVector();
      for (int i = 0; i < others.length-1; i++) {
        resultantVector = handles[i].sum(resultantVector);
      }     
      vec = resultantVector;
    }
  }
  
  void overEvent() {
    int boxx = int(x+vec.x - size/2);
    int boxy = int(y+vec.y - size/2);    
    if (overRect(boxx, boxy, size, size)) {
      over = true;
    } else {
      over = false;
    }
  }
  
  void pressEvent() {
    if (over && mousePressed || locked) {
      press = true;
      locked = true;
    } else {
      press = false;
    }
  }
  
  void releaseEvent() {
    locked = false;
  }
  
  void display() {
    renderLine();

    if(!isResultant)
    {
      renderHead();
    }
    
    renderName();

  }
  
  
  // render the Line
  void renderLine()
  {
     // Draw the line
    if(isResultant)
    {
     stroke(204, 102, 0); 
    }
    line(x, y, x+vec.x, y+vec.y);
    fill(255);
    stroke(0); 
  }
  
  // Render the vector head point
  void renderHead()
  {
      int boxx = int(x+vec.x - size/2);
      int boxy = int(y+vec.y - size/2);
      rect(boxx, boxy, size, size);
      
      // Highlight the head of the vector line
      if (over || press) {
        line(boxx, boxy, boxx+size, boxy+size);
        line(boxx, boxy+size, boxx+size, boxy);
      }    
  }
  
  // Print the vector name
  void renderName()
  {
      int boxx = int(x+vec.x - size/2) - 10;
      int boxy = int(y+vec.y - size/2) - 10;        
      text(_name, boxx, boxy);
  }
  
  void renderDirection()
  {
      int boxx = int(x+vec.x / 3 - size/2);
      int boxy = int(y+vec.y / 3 - size/2);        
      text(vec.heading(), boxx, boxy);
      println(vec.heading());
  }
}


// HELPER FUNCTIONS

boolean overRect(int x, int y, int width, int height) {
  if (mouseX >= x && mouseX <= x+width && 
      mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}

int lock(int val, int minv, int maxv) { 
  return  min(max(val, minv), maxv); 
} 