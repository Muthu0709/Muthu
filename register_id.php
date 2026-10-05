<?php
header("Content-Type: application/json");

$servername = "localhost";
$username   = "root";
$password   = "";
$dbname     = "student_management";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    echo json_encode([
        "success" => false,
        "message" => "Database connection failed."
    ]);
    exit;
}

$student_name  = trim($_POST["student_name"] ?? "");
$student_id    = trim($_POST["student_id"] ?? "");
$department    = trim($_POST["department"] ?? "");
$year          = trim($_POST["year"] ?? "");
$date_of_birth = trim($_POST["date_of_birth"] ?? "");
$college_name  = trim($_POST["college_name"] ?? "");
$phone_number  = trim($_POST["phone_number"] ?? "");

if (
    $student_name === "" ||
    $student_id === "" ||
    $department === "" ||
    $year === "" ||
    $date_of_birth === "" ||
    $college_name === "" ||
    $phone_number === ""
) {
    echo json_encode([
        "success" => false,
        "message" => "Please fill all details."
    ]);
    $conn->close();
    exit;
}

/* Student ID must already exist in the students table. */
$check = $conn->prepare(
    "SELECT student_id FROM students WHERE student_id = ?"
);
$check->bind_param("s", $student_id);
$check->execute();
$result = $check->get_result();

if ($result->num_rows === 0) {
    echo json_encode([
        "success" => false,
        "message" => "Student ID is not registered. Add the student first."
    ]);
    $check->close();
    $conn->close();
    exit;
}
$check->close();

/* Insert a new ID-card record or update the existing one. */
$sql = "INSERT INTO id_card_registrations
        (student_id, student_name, department, year, date_of_birth,
         college_name, phone_number)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
        student_name = VALUES(student_name),
        department = VALUES(department),
        year = VALUES(year),
        date_of_birth = VALUES(date_of_birth),
        college_name = VALUES(college_name),
        phone_number = VALUES(phone_number)";

$stmt = $conn->prepare($sql);

if (!$stmt) {
    echo json_encode([
        "success" => false,
        "message" => "SQL error: " . $conn->error
    ]);
    $conn->close();
    exit;
}

$stmt->bind_param(
    "sssssss",
    $student_id,
    $student_name,
    $department,
    $year,
    $date_of_birth,
    $college_name,
    $phone_number
);

if ($stmt->execute()) {
    echo json_encode([
        "success" => true,
        "message" => "ID Card Registered Successfully and saved to database!"
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Failed to save: " . $stmt->error
    ]);
}

$stmt->close();
$conn->close();
?>
