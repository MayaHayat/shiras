import java.awt.*;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.FileReader;
import javax.swing.JOptionPane;

ArrayList<Button> buttons = new ArrayList<Button>(); //store default buttons
ArrayList<Button> shapeButtons = new ArrayList<Button>(); //store shape buttons
ArrayList<Button> selectedShapeButtons = new ArrayList<Button>(); // store color, rotate, resize and move button
ArrayList<Button> colorButtons = new ArrayList<>();
ArrayList<Shape> shapes = new ArrayList<Shape>(); //store Shapes

boolean drawButtonActive = false; //Track state of the Draw Button
boolean selectedShapeButtonsActive = false; //Track state of additional buttons for shape
Shape pendingShape = null;

boolean moveModeActive = false;
Shape shapeBeingMoved = null;
float offsetX, offsetY;
float initialMouseX, initialMouseY;
ArrayList<Shape> shapesBeingMoved = new ArrayList<>();

boolean rotateModeActive = false;
Shape shapeBeingRotated = null;
float initialRotationAngle = 0;
float initialMouseAngle = 0;
//For rotating multiple shapes
ArrayList<Shape> shapesBeingRotated = new ArrayList<>();
ArrayList<Float> initialRotationAngles = new ArrayList<>();
PVector rotationCenter = new PVector();
float initialRotateMouseAngle = 0;

boolean colorModeActive = false;

String showInputDialog(String prompt) {
  return JOptionPane.showInputDialog(prompt);
}
//resize-mode
boolean resizeModeActive = false;
float resizeScrollStep = 2; //Amount to change size per mouse wheel tick

//Size for menu and canvas
final int menuWidth = 200;
final int canvasWidth = 1000;
final int canvasHeight = 600;
//Predefinded Filename
String filename = "shapes_data.txt";
File saveFile;

int rectangleButtonX = 200, rectangleButtonY=20;
void setup() {
  size(1200, 600);
  //create all Buttons for Menu
  String[] labels = {"Draw", "Bring forwards", "Send backwards", "Open file", "Save"};
  int startY = 20;
  int spacing = 80;
  for (int i = 0; i<labels.length; i++) {
    buttons.add(new Button(0, startY + i * spacing, labels[i]));
  }
  //create shape button
  shapeButtons.add(new Button(200, 20, "Rectangle"));
  shapeButtons.add(new Button(200, 70, "Circle"));
  shapeButtons.add(new Button(200, 120, "Star"));

  //create selectedShapeButtons
  selectedShapeButtons.add(new Button(300, 0, "Color"));
  selectedShapeButtons.add(new Button(300, 0, "Rotate"));
  selectedShapeButtons.add(new Button(0, 0, "Resize"));
  selectedShapeButtons.add(new Button(0, 0, "Move"));
  selectedShapeButtons.add(new Button(0, 0, "Add Text"));

  //create color buttons
  colorButtons.add(new Button(0, 0, "Red"));
  colorButtons.add(new Button(0, 0, "Green"));
  colorButtons.add(new Button(0, 0, "Blue"));
  colorButtons.add(new Button(0, 0, "Yellow"));

  for (Button b : colorButtons) {
    b.visible = false;
  }

  //Initialize file object for save
  String dataPath = dataPath(filename);
  saveFile =new File(dataPath);

  //create the file if it does not exist
  if (!saveFile.exists()) {
    try {
      saveFile.createNewFile();
    }
    catch(IOException e) {
      e.printStackTrace();
    }
  }

  // Set their visibility to false initially

  for (Button b : selectedShapeButtons) {

    b.visible = false;
  }
}

void draw() {
  //When background color is adjusted also do in else switch "Draw"
  background(255);
  //Draw menu sidebar
  fill(230);
  noStroke();
  rect(0, 0, menuWidth, canvasHeight);

    handleButtonList(buttons);
    
    if (drawButtonActive) {
        handleButtonList(shapeButtons);
    }
    
    handleButtonList(selectedShapeButtons);
    handleButtonList(colorButtons);
    
    if (pendingShape != null) {
        pendingShape.setX(mouseX);
        pendingShape.setY(mouseY);
        pendingShape.display();
    }
    
    for (Shape s : shapes) {
        s.display();
    }
}

void handleButtonList(ArrayList<Button> buttonList) {
    for (Button b : buttonList) {
        if (b.visible) { // Check visibility before processing
            if (b.isMouseOver()) {
                b.setMouseOverColor();
            } else {
                b.setDefaultColor();
            }
            b.display();
        }
    }
}

//Save shapes to file
void saveToFile() {
  //File saveFile = new File(filename);
    try(BufferedWriter writer = new BufferedWriter(new FileWriter(saveFile))) {
        for (Shape s : shapes) {
            color shapeColor = s.getShapeColor(); // Get the color
            int red = (shapeColor >> 16) & 0xFF;
            int green = (shapeColor >> 8) & 0xFF;
            int blue = (shapeColor) & 0xFF;
          String shapeTypeStr = "Unknown"; // Default in case of an unexpected shape type
      if (s instanceof RectangleShape) {
        shapeTypeStr = "Rectangle";
      } else if (s instanceof CircleShape) {
        shapeTypeStr = "Circle";
      } else if (s instanceof StarShape) {
        shapeTypeStr = "Star";
      }
       String textContent = s.getText();
      if (textContent == null) { // Ensure textContent is not null for saving
          textContent = "";
      }
        String data = shapeTypeStr + "," +
                    s.getX() + "," +
                    s.getY() + "," +
                    s.getSize() + "," +
                    s.getRotation() + "," +
                    red + "," +
                    green + "," +
                    blue + "," +
                    textContent + "\n"; // textContent is the last field
      writer.write(data);
        }
    } catch(IOException e) {
        e.printStackTrace();
    }
}

//load from file
void loadFromFile() {
shapes.clear(); // Clear existing shapes
  try (BufferedReader reader = new BufferedReader(new FileReader(saveFile))) {
    String line;
    while ((line = reader.readLine()) != null) {
      // Use split with -1 limit to preserve trailing empty strings (e.g., if text is empty)
      String[] parts = line.split(",", -1); 
      if (parts.length == 9) { 
        try {
          String shapeTypeFromFile = parts[0]; // 1st part is shape type
          float x = Float.parseFloat(parts[1]);
          float y = Float.parseFloat(parts[2]);
          float size = Float.parseFloat(parts[3]);
          float rotation = Float.parseFloat(parts[4]);
          int red = Integer.parseInt(parts[5]);
          int green = Integer.parseInt(parts[6]);
          int blue = Integer.parseInt(parts[7]);
          color shapeColor = color(red, green, blue);
          String textContent = parts[8]; // 9th part is text content

          Shape s = null;
          switch (shapeTypeFromFile) {
            case "Rectangle":
              s = new RectangleShape(x, y);
              break;
            case "Circle":
              s = new CircleShape(x, y);
              break;
            case "Star":
              s = new StarShape(x, y);
              break;
            // Add other 'case' blocks here if you add more shape subclasses
            default:
              println("Unknown shape type in file: '" + shapeTypeFromFile + "'");
              continue; // Skip this unknown shape and go to the next line
          }

          if (s != null) {
            s.setSize(size);
            s.setRotation(rotation);
            s.setShapeColor(shapeColor);
            s.setText(textContent); // Set the text content
            shapes.add(s);
          }
        } catch (NumberFormatException e) {
          println("Error parsing number in line: \"" + line + "\" - " + e.getMessage());
        } catch (Exception e) { // Catch any other potential errors during shape processing
            println("Error processing line: \"" + line + "\" - " + e.getMessage());
        }
      } else {
        println("Skipping invalid line (expected 9 parts, got " + parts.length + "): \"" + line + "\"");
      }
    }
  } catch (IOException e) {
    e.printStackTrace();
    println("Error loading shapes from file: " + e.getMessage());
  }
}

//When mouse clicks button
void mousePressed() {
  boolean clickedOnButton = false;

  for (Button b : colorButtons) {
    if (b.isMouseOver() && b.visible) {
      color selectedColor = color(0);
      switch (b.label) {
      case "Red":
        selectedColor = color(255, 0, 0);
        break;
      case "Green":
        selectedColor = color(0, 255, 0);
        break;
      case "Blue":
        selectedColor = color(0, 0, 255);
        break;
      case "Yellow":
        selectedColor = color(255, 255, 0);
        break;
      }

      // Apply color to selected shapes
      for (Shape s : shapes) {
        if (s.isSelected()) {
          s.setShapeColor(selectedColor);
        }
      }
      // Hide color buttons after selection
      for (Button cb : colorButtons) {
        cb.visible = false;
      }
      colorModeActive = false;  // Reset mode flag
      return;  // Exit the loop after a color is applied
    }
  }

  for (Button b : buttons) {
    if (b.isMouseOver()) {
     clickedOnButton = true;
      break;
    }
  }
  for (Button b : shapeButtons) {
    if (b.isMouseOver()) {
      clickedOnButton = true;
      break;
    }
  }

  for (Button b : selectedShapeButtons) {
    if (b.isMouseOver()) {
      clickedOnButton = true;
      break;
    }
  }
  shapesBeingMoved.clear();
  initialMouseX = mouseX;
  initialMouseY = mouseY;

  if (moveModeActive) {
    for (Shape s : shapes) {
      if (s.isSelected()) {
        shapesBeingMoved.add(s);
      }
    }
  }
  if (pendingShape != null) {
    //place the shape at current location
    shapes.add(pendingShape);
    pendingShape = null;
  }

  boolean shapeSelected = false;
  // Toggle selection for shapes under the mouse
  for (Shape s : shapes) {
    if (s.isMouseOverShape(mouseX, mouseY)) {
      s.setSelected(!s.isSelected());
      shapeSelected = true;
    }
  }

  //Code goes here to update selectedShapeButtonsActive and visibility
  if (!shapeSelected && !clickedOnButton) {
    selectedShapeButtonsActive = false;
    for (Button b : selectedShapeButtons) {
      b.visible = false;
    }
    for (Shape s : shapes) {
      s.setSelected(false);
    }
  } else {
    selectedShapeButtonsActive = true;
    // Position the buttons and set visible = true
    int buttonSpacing = 10;
    int buttonWidth = 80; // approximate width
    int startX = (width - ((buttonWidth + buttonSpacing) * selectedShapeButtons.size() - buttonSpacing)) / 2;
    int yPos = height - 50;
    for (int i = 0; i < selectedShapeButtons.size(); i++) {
      Button b = selectedShapeButtons.get(i);
      b.setPositionAndVisibility(startX + i * (buttonWidth + buttonSpacing), yPos, true);
    }
  }

  //handle button clicks
  for (Button b : buttons) {
    if (b.isMouseClicked()) {
      b.active = !b.active; //active on / off
      doAction(b.label, b.active);
    }
  }
  //handle shape button clicks
  for (Button b : shapeButtons) {
    if (b.isMouseClicked()) {
      b.active = !b.active; //active on / off
      doAction(b.label, b.active);
    }
  }

  for (Button b : selectedShapeButtons) {
    if (b.isMouseClicked()) {
      b.active = !b.active; //active on / off
      doAction(b.label, b.active);
    }
  }

  //deselect all shapes if none were selected
  if (rotateModeActive) {
    shapesBeingRotated.clear();
    initialRotationAngles.clear();
    float sumX = 0;
    float sumY = 0;
    int count = 0;

    for (Shape s : shapes) {
      if (s.isSelected()) {
        shapesBeingRotated.add(s);
        initialRotationAngles.add(s.getRotation());
        sumX += s.getX();
        sumY += s.getY();
        count++;
      }
    }

    if (count > 0) {
      rotationCenter.set(sumX / count, sumY / count);
      initialRotateMouseAngle = atan2(mouseY - rotationCenter.y, mouseX - rotationCenter.x);
    }
  }

  if (!shapeSelected) {
    for (Shape s : shapes) {
      s.setSelected (false);
    }
  }
}



//detailing what to do when specific button is clicked
void doAction(String label, boolean active) {
  if (active) {
    switch (label) {
    case "Draw":
      //generate shape buttons
      drawButtonActive = active;
      for (Button b : shapeButtons) {
        b.visible = drawButtonActive;
      }
      break;
    case "Move":
      moveModeActive = active;
      //Hide all shape buttons when Move is active
      for (Button b : selectedShapeButtons) {
        if (!b.label.equals("Move")) {
          b.visible = !moveModeActive;  // hide if moveModeActive is true
        }
      }
      break;

    case "Bring forwards":
      bringSelectedShapesToFront();
      for (Button originalButton : buttons) {
        if (originalButton.label.equals("Bring forwards")) {
          originalButton.active = false;
          break;
        }
      }
      break;

    case "Send backwards":
      sendSelectedShapesToBack();
      for (Button originalButton : buttons) {
        if (originalButton.label.equals("Send backwards")) {
          originalButton.active = false;
          break;
        }
      }
      break;

    case "Color":
      colorModeActive = active;
      int colorButtonSpacing = 10;
      int colorButtonWidth = 60;
      int totalWidth = colorButtons.size() * (colorButtonWidth + colorButtonSpacing) - colorButtonSpacing;
      int colorStartX = (width - totalWidth) / 2;
      int colorY = height - 100;

      for (int i = 0; i < colorButtons.size(); i++) {
        Button cb = colorButtons.get(i);
        cb.setPositionAndVisibility(colorStartX + i * (colorButtonWidth + colorButtonSpacing), colorY, true);
      }

      if (colorModeActive) {
        // Optionally hide other buttons (like in rotate/move)
        for (Button b : selectedShapeButtons) {
          if (!b.label.equals("Color")) {

            b.visible = false;
          }
        }
      }
      break;

    case "Open file":
      loadFromFile();
      break;
      
    case "Save":
      saveToFile();
      break;

    case "Add Text":
      String input = showInputDialog("Enter text for selected shapes:");
      if (input != null && !input.trim().isEmpty()) {
        for (Shape s : shapes) {
          if (s.isSelected()) {
            s.setText(input);
          }
        }
      }
      // Deactivate the button after action
      for (Button b : selectedShapeButtons) {
        if (b.label.equals("Add Text")) {
          b.active = false;
          break;
        }
      }
      break;
    case "Rotate":
      rotateModeActive = active;
      if (rotateModeActive) {
        for (Button b : selectedShapeButtons) {
          if (!b.label.equals("Rotate")) {
            b.visible = false;
          }
        }
      }
      break;
    case "Rectangle":
      pendingShape = new RectangleShape(mouseX, mouseY);
      break;
    case "Circle":
      pendingShape = new CircleShape(mouseX, mouseY);
      break;
    case "Star":
      pendingShape = new StarShape(mouseX, mouseY);
      break;
    case "Resize":
      resizeModeActive = active;

      break;
    }
  } else {
    switch(label) {
    case "Draw":
      drawButtonActive = false;
      for (Button b : shapeButtons) {
        b.visible = false;
        fill(255);
        noStroke();
        rect(b.x, b.y, b.width, b.height);
      }
      break;
      
       case "Move":
                moveModeActive = false;
                shapesBeingMoved.clear();
                break;
            
            case "Rotate":
                rotateModeActive = false;
                break;
            
            case "Resize":
                resizeModeActive = false;
                break;
            
            case "Color":
                colorModeActive = false;
                break;

    }
  }
}

void mouseDragged() {
  if (moveModeActive && !shapesBeingMoved.isEmpty()) {
    float dx = mouseX - initialMouseX;
    float dy = mouseY - initialMouseY;

    for (Shape s : shapesBeingMoved) {
      s.setX (s.getX() + dx);
      s.setY (s.getY() + dy);
    }
    initialMouseX = mouseX;
    initialMouseY = mouseY;
  }

  if (rotateModeActive && !shapesBeingRotated.isEmpty()) {
    float currentAngle = atan2(mouseY - rotationCenter.y, mouseX - rotationCenter.x);
    float deltaAngle = degrees(currentAngle - initialRotateMouseAngle);

    for (int i = 0; i < shapesBeingRotated.size(); i++) {
      Shape s = shapesBeingRotated.get(i);
      float originalAngle = initialRotationAngles.get(i);
      s.setRotation(originalAngle + deltaAngle);
    }
  }
}

void mouseReleased() {
  if (moveModeActive) {
    shapesBeingMoved.clear();
  }

  if (rotateModeActive) {
    shapesBeingRotated.clear();
    initialRotationAngles.clear();
  }
}

void sendSelectedShapesToBack() {
  ArrayList<Shape> selectedShapesToSort = new ArrayList<Shape>();
  for (Shape s : shapes) {
    if (s.isSelected()) {
      selectedShapesToSort.add(s);
    }
  }

  if (!selectedShapesToSort.isEmpty()) {
    // remove selected shape from main shapelist
    shapes.removeAll(selectedShapesToSort);

    // Enter selected shape to beginning of shape list
    shapes.addAll(0, selectedShapesToSort);
    // deselect shapes
    for (Shape s : selectedShapesToSort) {
      s.setSelected(false);
    }
    selectedShapeButtonsActive = false;
    for (Button b : selectedShapeButtons) {
      b.visible = false;
    }
  }
}

void bringSelectedShapesToFront() {
  ArrayList<Shape> selectedShapesToSort = new ArrayList<Shape>();
  for (Shape s : shapes) {
    if (s.isSelected()) {
      selectedShapesToSort.add(s);
    }
  }

  if (!selectedShapesToSort.isEmpty()) {
    shapes.removeAll(selectedShapesToSort);
    shapes.addAll(selectedShapesToSort);
    for (Shape s : selectedShapesToSort) {
      s.setSelected(false);
    }
    selectedShapeButtonsActive = false;
    for (Button b : selectedShapeButtons) {
      b.visible = false;
    }
  }
}

void mouseWheel(MouseEvent event) {
  if (resizeModeActive) {
    boolean canResizeWithWheel = false;
    if (mouseX > menuWidth) {
      for (Shape s : shapes) {
        if (s.isSelected()) {
          canResizeWithWheel = true;
        }
      }
    }

    if (canResizeWithWheel) {
      float scrollRotation = event.getCount();
      float sizeChangeDueToScroll = scrollRotation * resizeScrollStep;
      for (Shape s : shapes) {
        if (s.isSelected()) {
          float currentSize = s.getSize();
          float newSize = currentSize + sizeChangeDueToScroll;
          s.setSize(max(5, newSize)); // Apply new size with a minimum of 5
        }
      }
    }
  }
}
