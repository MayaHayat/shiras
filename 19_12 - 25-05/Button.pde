public class Button {
  private float x, y;
  private String label;
  
  private int padding = 15;
  private color buttonColor;
  private color textColor;
  private float width, height;
  private boolean active = false;
  private boolean visible = true;
  private int defaultButtonColor = color(129, 220, 255);
  private int mouseOverColor = color(191, 237, 255);

  // Constructor
  Button(int x, int y, String label) {
    this.x = x;
    this.y = y;
    this.label = label;
    this.buttonColor = defaultButtonColor;
    this.textColor = color(0);
    this.width = textWidth(label) + padding * 2; // Width based on original label
    this.height = textAscent() + textDescent() + padding * 2;
  }

  public void display() {
    if (this.visible) {
      pushStyle();

      color currentFill = this.buttonColor;
      fill(currentFill);
      rect(this.x, this.y, this.width, this.height);

      String textToDisplay = this.label; // Default to the original label
      if (this.active) {
        // Customize text for specific active buttons
        if (this.label.equals("Resize")) {
          textToDisplay = "Resize ON";
        } else if (this.label.equals("Move")) {
          textToDisplay = "Move ON";
        } else if (this.label.equals("Rotate") && this.active) {
          textToDisplay = "Rotate ON"; //
        }
      }
      
      fill(this.textColor);
      textAlign(CENTER, CENTER);
      textSize(14);
      text(textToDisplay, this.x + this.width / 2, this.y + this.height / 2);
      popStyle();
    }
  }  
  
  public void setActive(boolean active) {
    this.active = active;
  }
  public boolean isActive() {
    return this.active;
  }
  public boolean isMouseOver() {
    return visible && mouseX > x && mouseX < x + width && mouseY > y && mouseY < y + height;
  }
  public boolean isMouseClicked() {
    return isMouseOver() && mousePressed;
  }
  public void setPositionAndVisibility(int newX, int newY, boolean isVisible) {
    this.x = newX;
    this.y = newY;
    this.visible = isVisible;
  }
  
  public void setDefaultColor() {
    if (!this.active) {
      this.buttonColor = defaultButtonColor;
    }
  }

  public void setMouseOverColor() {
    if (!this.active) {
      this.buttonColor = mouseOverColor;
    }
  }
}
