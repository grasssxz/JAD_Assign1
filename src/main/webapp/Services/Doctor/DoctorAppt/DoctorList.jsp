<jsp:include page="/auth/SessisonInit.jsp" />


<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Find a Doctor</title>

<!-- Tailwind CDN -->
<script src="https://cdn.tailwindcss.com"></script>

</head>

<body class="bg-gray-100">

<!-- ==========================================================
     NAVIGATION BAR (Loaded via fetch)
============================================================== -->
<div id="navbar-container"></div>

<script>
const navUrl = "<%= request.getContextPath() %>/home/NavBar.jsp";

fetch(navUrl)
    .then(res => res.text())
    .then(html => {
        document.getElementById("navbar-container").innerHTML = html;
    })
    .catch(err => console.error("Navbar load error:", err));
</script>


<!-- ==========================================================
     PAGE HEADER
============================================================== -->
<section class="max-w-7xl mx-auto px-6 py-6">
    <h1 class="text-3xl font-bold text-gray-800 mb-4">Find a Doctor</h1>

    <div class="flex flex-col md:flex-row gap-6">

        <!-- ==========================================================
             FILTER PANEL
        =============================================================== -->
        <div class="w-full md:w-1/3 bg-white p-6 rounded-xl shadow">

            <h2 class="text-xl font-semibold mb-4">Filters</h2>

            <form id="filterForm" class="space-y-4">

                <div>
                    <label class="font-medium block mb-1">Search Name</label>
                    <input type="text" name="name" placeholder="e.g. Jenny"
                           class="w-full px-4 py-2 border rounded-lg focus:ring focus:outline-none" />
                </div>

                <div>
                    <label class="font-medium block mb-1">Specialty</label>
                    <select name="specialty"
                            class="w-full px-4 py-2 border rounded-lg focus:ring focus:outline-none">
                        <option value="">Any</option>
                        <option value="Immunologist">Immunologist</option>
                        <option value="Cardiologist">Cardiologist</option>
                        <option value="Dermatologist">Dermatologist</option>
                    </select>
                </div>

                <div>
                    <label class="font-medium block mb-1">Minimum Experience (Years)</label>
                    <select name="experience"
                            class="w-full px-4 py-2 border rounded-lg focus:ring focus:outline-none">
                        <option value="">Any</option>
                        <option value="5">5+ years</option>
                        <option value="10">10+ years</option>
                        <option value="15">15+ years</option>
                    </select>
                </div>

                <div>
                    <label class="font-medium block mb-1">Minimum Rating</label>
                    <select name="rating"
                            class="w-full px-4 py-2 border rounded-lg focus:ring focus:outline-none">
                        <option value="">Any</option>
                        <option value="3">3★ &amp; up</option>
                        <option value="4">4★ &amp; up</option>
                        <option value="5">5★ only</option>
                    </select>
                </div>

                <button type="submit"
                        class="w-full bg-blue-600 hover:bg-blue-700 text-white py-2 rounded-lg font-semibold">
                    Apply Filters
                </button>

            </form>
        </div>

        <!-- ==========================================================
             RESULTS PANEL — IFRAME
        =============================================================== -->
        <div class="w-full md:w-2/3">
            <iframe id="doctorResults"
                    class="w-full h-[650px] rounded-xl shadow bg-white border"></iframe>
        </div>

    </div>
</section>


<!-- ==========================================================
     SCRIPT — FILTER LOGIC
============================================================== -->
<script>
// Default load
document.getElementById("doctorResults").src =
    "<%= request.getContextPath() %>/Services/Doctor/DoctorAppt/DoctorListResults.jsp";


/// Default load
document.getElementById("doctorResults").src =
    "<%= request.getContextPath() %>/Services/Doctor/DoctorAppt/DoctorListResults.jsp";

// Filter submit
document.getElementById("filterForm").addEventListener("submit", function (e) {
    e.preventDefault();

    const params = new URLSearchParams(new FormData(this)).toString();

    document.getElementById("doctorResults").src =
        "<%= request.getContextPath() %>/Services/Doctor/DoctorAppt/DoctorListResults.jsp?" + params;
});

</script>

</body>
</html>
