public abstract class Shape {
  protected float x, y; // position of the shape
  protected color shapeColor; // color of the shape (using java.awt.Color)
  protected float size;
  protected float rotation;
  protected boolean isSelected; // tracks if the shape is currently selected
  protected String text = ""; // Default empty

  Shape(float x, float y) {
    this.x = x;
    this.y = y;
    this.shapeColor = color(255, 0, 0); // default color is white (using RGB for java.awt.Color)
    this.size = 50; // default size
    this.rotation = 0;
    this.isSelected = false; // although initialized this way, ensuring that it's false
  }

  public void display() {
    // Assuming you have a graphics context 'g' to draw with (like in Swing's paintComponent method)
    // and methods like pushMatrix(), translate(), rotate(), noStroke(), fill(), rectMode(), rect(),
    // ellipseMode(), ellipse(), drawStar(), popMatrix() are available in that context or a library you're using.
    pushMatrix();
    translate(x, y);
    rotate(radians(rotation));
    stroke(0);
    fill(shapeColor);
    
    if (isMouseOverShape(mouseX, mouseY)) {
      stroke (8, 0, 0);
      strokeWeight(3);
    } else {
      stroke(0);
      strokeWeight(0);
    }
    fill(shapeColor);

    drawSpecificShape();
    if (isSelected) {
      // drawing selection outline
      noFill();
      stroke(0, 0, 255);
      strokeWeight(3);
      drawSelectionOutline();
      strokeWeight(1);
      stroke(0); // to reset stroke
    }
    popMatrix();

    if (!text.equals("")) {
      fill(0); // text color
      textAlign(CENTER, CENTER);
      textSize(16);
      pushMatrix();
      translate(x, y);
      rotate(radians(rotation));
      text(text, 0, 0);  // Draw text at center of shape
      popMatrix();
    }
  }

  protected abstract void drawSpecificShape();
  protected abstract void drawSelectionOutline();
  public abstract boolean isMouseOverShape(float mx, float my);
  
  // Getters & Setters
  public float getX() {
    return x;
  }
  public void setX(float x) {

    this.x = x;
  }
  public float getY() {
    return y;
  }
  public void setY(float y) {
    this.y = y;
  }
  public void setText(String text) {
    this.text = text;
  }
  public String getText() {
    return this.text;
  }
  public color getShapeColor() {
    return shapeColor;
  }
  public void setShapeColor(color c) {
    this.shapeColor = c;
  }
  public float getSize() {
    return size;
  }
  public void setSize(float size) {
    this.size = size;
  }
  public float getRotation() {
    return rotation;
  }
  public void setRotation(float rotation) {
    this.rotation = rotation;
  }
  public boolean isSelected() {
    return isSelected;
  }
  public void setSelected(boolean selected) {
    isSelected = selected;
  }
}
