# Install mysql-connector-python
# !pip install mysql-connector-python

# Import pickle
import pickle
import mysql.connector

# Get filepaths of all SQL files in submissions folder
import glob
import os

sql_files = glob.glob(os.path.join("submissions", "*.sql"))
sql_files.sort()

question_points = [5, 10, 10, 5, 10, 10, 10, 15, 10, 15, 10, 10, 10, 10, 10]

expected_answers = []
# Read answers from expected_answers.pkl
with open("./expected_answers.pkl", "rb") as f:
    expected_answers = pickle.load(f)

# Connect to your MySQL DB Instance.

db = mysql.connector.connect(
    host="localhost",
    user="root",
    passwd="",
    database="travel_reservation_service"
)

# Delete file scores.txt if it exists
if os.path.exists("scores.txt"):
    os.remove("scores.txt")

# Delete all files in grading_reports folder
for file in glob.glob(os.path.join("grading_reports", "*")):
    os.remove(file)

for submission in sql_files:
    cursor = db.cursor(buffered=True)
    
    cursor.execute("DROP VIEW IF EXISTS query_1, query_2, query_3, query_4, query_5, query_6, query_7, query_8, query_9, query_10, query_11, query_12, query_13, query_14, query_15;")
    cursor.close()
    
    # Run the entire SQL file
    with open(submission, "r") as f:
        cursor = db.cursor(buffered=True)
        cursor.execute(f.read())
        cursor.close()

    student_score = 0

    query_template = "SELECT * FROM query_{};"

    # Connect to your MySQL DB Instance.

    db = mysql.connector.connect(
        host="localhost",
        user="root",
        passwd="",
        database="travel_reservation_service"
    )

    for i in range(1, 16):
        cursor = db.cursor(buffered=True)

        # Try to execute the query
        try:
            cursor.execute(query_template.format(i))
        except Exception as e:
            with open("./grading_reports/" + submission[12:-3] + ".txt", "a") as f:
                f.write("Query {}: Incorrect\n".format(i))
                f.write("Submission: {}, Error in query {}: {}\n".format(submission, i, e))
                f.write("\n\n")
                f.close()
            cursor.close()
            continue
            

        # Get result of the query
        result = cursor.fetchall()


        if (i == 0 or i == 1 or i == 2 or i == 3 or i == 4 or i == 7 or i == 8 or i == 9 or i == 10 or i == 11 or i == 12 or i == 13 or i == 14 or i == 15) and len(result) == len(expected_answers[i-1]) and all(row in expected_answers[i-1] for row in result) and all(row in result for row in expected_answers[i-1]):
            student_score += question_points[i-1]
        elif result == expected_answers[i - 1]:
            student_score += question_points[i - 1]
        else:
            with open("./grading_reports/" + submission[12:-3] + ".txt", "a") as f:
                f.write("Query {}: Incorrect\n".format(i))
                f.write("Expected:\n")
                # Pretty print the expected answer
                for row in expected_answers[i - 1]:
                    f.write(str(row) + "\n")
                f.write("Got:\n")
                # Pretty print the result
                for row in result:
                    f.write(str(row) + "\n")
                f.write("\n\n")
                f.close()

        cursor.close()

    # Drop all views
    cursor = db.cursor(buffered=True)
    cursor.execute("DROP VIEW IF EXISTS query_1, query_2, query_3, query_4, query_5, query_6, query_7, query_8, query_9, query_10, query_11, query_12, query_13, query_14, query_15;")
    cursor.close()

    # Get list of all views in database
    cursor = db.cursor(buffered=True)
    cursor.execute("SHOW FULL TABLES IN travel_reservation_service WHERE TABLE_TYPE LIKE 'VIEW';")
    views = cursor.fetchall()
    cursor.close()

    # Drop all views
    for view in views:
        cursor = db.cursor(buffered=True)
        cursor.execute("DROP VIEW IF EXISTS {};".format(view[0]))
        cursor.close()
    
    
    # Append score to file scores.txt
    with open("scores.txt", "a") as f:
        f.write(submission + ": " + str(student_score) + "\n")