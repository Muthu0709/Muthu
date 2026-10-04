<?php

// Database connection
$servername = "localhost";
$username   = "root";
$password   = "";
$dbname     = "student_management";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Database Connection Failed: " . $conn->connect_error);
}


// Login details from HTML form
$student_id = $_POST['student_id'];
$password_input = $_POST['password'];


// Check student login
$sql = "SELECT * FROM students 
        WHERE student_id = ? AND password = ?";

$stmt = $conn->prepare($sql);

$stmt->bind_param("ss", $student_id, $password_input);

$stmt->execute();

$result = $stmt->get_result();


// Login success / failure
if ($result->num_rows > 0) {

    echo "Login Successful";

} else {

    echo "Invalid Student ID or Password";

}


$stmt->close();
$conn->close();

?>
