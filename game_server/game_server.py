from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
import os
import sys


app = Flask(__name__)

# Database setup (SQLite as a file-based DB)
BASE_DIR = os.path.abspath(os.path.dirname(__file__))
DB_PATH = os.path.join(BASE_DIR, "game_server.db")
app.config["SQLALCHEMY_DATABASE_URI"] = f"sqlite:///{DB_PATH}"
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

db = SQLAlchemy(app)

class Player(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50), nullable=False, unique=True)
    character_class = db.Column(db.String(50), nullable=False)
    race = db.Column(db.String(50), nullable=False)
    faction = db.Column(db.String(50), nullable=False)
    background = db.Column(db.String(50), nullable=False)
    starting_area = db.Column(db.String(50), nullable=False)

    def __init__(self, name, character_class, race, faction, background, starting_area):
        self.name = name
        self.character_class = character_class
        self.race = race
        self.faction = faction
        self.background = background
        self.starting_area = starting_area

@app.route("/")
def home():
    return jsonify({"message": "Game API is running!"})

@app.route("/check_name_avail", methods=["GET"])
def check_name_avail():
    """Check if a player name is available."""
    name = request.args.get("name", "").strip()  # Ensures name is not None and removes extra spaces
    if not name:
        return jsonify({"error": "No name provided."}), 400

    # Query the database to check if the name exists
    player = Player.query.filter_by(name=name).first()
    if player:
        return jsonify({"available": False, "message": "Name is taken."}), 200
    else:
        return jsonify({"available": True, "message": "Name is available."}), 200

from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
import os
import sys


app = Flask(__name__)

# Database setup (SQLite as a file-based DB)
BASE_DIR = os.path.abspath(os.path.dirname(__file__))
DB_PATH = os.path.join(BASE_DIR, "game_server.db")
app.config["SQLALCHEMY_DATABASE_URI"] = f"sqlite:///{DB_PATH}"
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

db = SQLAlchemy(app)

class Player(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50), nullable=False, unique=True)
    character_class = db.Column(db.String(50), nullable=False)
    race = db.Column(db.String(50), nullable=False)
    faction = db.Column(db.String(50), nullable=False)
    background = db.Column(db.String(50), nullable=False)
    starting_area = db.Column(db.String(50), nullable=False)

    def __init__(self, name, character_class, race, faction, background, starting_area):
        self.name = name
        self.character_class = character_class
        self.race = race
        self.faction = faction
        self.background = background
        self.starting_area = starting_area

@app.route("/")
def home():
    return jsonify({"message": "Game API is running!"})

@app.route("/check_name_avail", methods=["GET"])
def check_name_avail():
    """Check if a player name is available."""
    name = request.args.get("name", "").strip()  # Ensures name is not None and removes extra spaces
    if not name:
        return jsonify({"error": "No name provided."}), 400

    # Query the database to check if the name exists
    player = Player.query.filter_by(name=name).first()
    if player:
        return jsonify({"available": False, "message": "Name is taken."}), 200
    else:
        return jsonify({"available": True, "message": "Name is available."}), 200

@app.route("/create_character", methods=["POST"])
def create_character():
    """Handles character creation from client POST request."""
    data = request.get_json()

    # Validate received data
    required_fields = ["name", "class", "race", "faction", "background", "area"]
    for field in required_fields:
        if field not in data or not data[field]:
            return jsonify({"error": f"Missing field: {field}"}), 400

    try:
        # Create new player entry
        new_player = Player(
            name=data["name"],
            character_class=data["class"],
            race=data["race"],
            faction=data["faction"],
            background=data["background"],
            starting_area=data["area"]
        )

        # Add to database
        db.session.add(new_player)
        db.session.commit()

        return jsonify({"success": True, "message": "Character created successfully!", "character_id": new_player.id}), 201

    except Exception as e:
        db.session.rollback()  # Rollback any issues that prevent committing
        print(f"Database error: {str(e)}")  # Print error to console
        return jsonify({"error": "Failed to create character. Please try again."}), 500

@app.route("/test")
def test_connection():
    """Check if 'Sarumae' exists in the Player table."""
    try:
        with app.app_context():
            sarumae = Player.query.filter_by(name="Sarumae").first()
            if sarumae:
                return jsonify({
                    "api_status": "running",
                    "db_status": "connected",
                    "player_exists": True
                })
            else:
                return jsonify({
                    "api_status": "running",
                    "db_status": "connected",
                    "player_exists": False
                }), 500
    except Exception as e:
        return jsonify({"api_status": "running", "db_status": f"error: {str(e)}"}), 500

# Run a startup test to ensure 'Sarumae' exists, else exit
def startup_test():
    try:
        with app.app_context():
            sarumae = Player.query.filter_by(name="Sarumae").first()
            if not sarumae:
                print("❌ ERROR: 'Sarumae' is missing from the Player table!")
                sys.exit(1)  # Exit if the test fails
            print("✅ Database check passed: 'Sarumae' exists.")
    except Exception as e:
        print(f"❌ Database connection failed: {e}")
        sys.exit(1)  # Exit on failure

if __name__ == "__main__":
    startup_test()  # Run test before launching server
    app.run(host="127.0.0.1", port=5000, debug=True)

@app.route("/test")
def test_connection():
    """Check if 'Sarumae' exists in the Player table."""
    try:
        with app.app_context():
            sarumae = Player.query.filter_by(name="Sarumae").first()
            if sarumae:
                return jsonify({
                    "api_status": "running",
                    "db_status": "connected",
                    "player_exists": True
                })
            else:
                return jsonify({
                    "api_status": "running",
                    "db_status": "connected",
                    "player_exists": False
                }), 500
    except Exception as e:
        return jsonify({"api_status": "running", "db_status": f"error: {str(e)}"}), 500

# Run a startup test to ensure 'Sarumae' exists, else exit
def startup_test():
    try:
        with app.app_context():
            sarumae = Player.query.filter_by(name="Sarumae").first()
            if not sarumae:
                print("❌ ERROR: 'Sarumae' is missing from the Player table!")
                sys.exit(1)  # Exit if the test fails
            print("✅ Database check passed: 'Sarumae' exists.")
    except Exception as e:
        print(f"❌ Database connection failed: {e}")
        sys.exit(1)  # Exit on failure

if __name__ == "__main__":
    startup_test()  # Run test before launching server
    app.run(host="127.0.0.1", port=5000, debug=True)
