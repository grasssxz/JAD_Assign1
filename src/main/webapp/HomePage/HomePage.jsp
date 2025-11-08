<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>Care Services - JSP</title>
<style>
  :root{ --purple:#d4d6e0; --purple-border:#7f9cf5; --banner:#aeb8d1; --pill:#faf9d7; --text:#111; }
  *{box-sizing:border-box}
  body{margin:0;font-family:Arial, Helvetica, sans-serif;color:var(--text);background:#fff}
  .navbar{background:var(--purple);border-bottom:2px solid var(--purple-border);padding:18px 28px;display:flex;align-items:center;justify-content:space-between}
  .nav-left,.nav-right{display:flex;align-items:center;gap:36px}
  .nav-link{color:#fff;text-decoration:none;font-weight:500}
  .nav-link:hover{text-decoration:underline}
  .icons-row{display:flex;justify-content:flex-end;gap:18px;margin:14px 28px 0}
  .icon-btn{font-size:22px;cursor:pointer}
  .profile{display:flex;align-items:center;gap:12px;margin:18px 28px}
  .avatar{width:46px;height:46px;border-radius:50%;object-fit:cover}
  .name{font-weight:600}
  .search-wrap{margin:14px 28px}
  .search{display:flex;align-items:center;background:#efecef;border-radius:8px;padding:12px 14px}
  .search input{border:0;outline:0;background:transparent;width:100%;font-size:16px}
  /* BANNER */
.banner{
  margin:20px 28px;
  border-radius:22px;
  overflow:hidden;
  position:relative;
  height:180px;            /* smaller (was 260px) */
  background:var(--banner);
}

/* SLIDE IMAGE */
.slide{
  position:absolute;
  top:0; bottom:0;         /* keep full banner height */
  right:0;                 /* stick to the right */
  width:55%;               /* image only takes right 55% */
  height:100%;
  object-fit:contain;      /* no crop/zoom */
  display:none;
  background:var(--banner);/* fills left area if image is narrow */
}
.slide.active{ display:block; animation:fade .9s ease-in-out; }

/* TEXT OVERLAY */
.banner-text{
  position:absolute;
  left:6%;                 /* closer to left */
  top:28%;
  width:40%;               /* keep text on left side */
  color:#fff;
  pointer-events:none;
  z-index:2;
}

  .banner-text h2{margin:0 0 6px;font-size:28px}
  .banner-text p{margin:0;opacity:.95}
  .dots{position:absolute;left:50%;bottom:16px;transform:translateX(-50%);display:flex;gap:10px}
  .dot{width:10px;height:10px;border-radius:50%;background:rgba(255,255,255,.55);cursor:pointer}
  .dot.active{background:#fff}
  .services-head{display:flex;justify-content:center;margin:22px 0 8px}
  .pill{background:var(--pill);padding:8px 20px;border-radius:6px;font-weight:700}
  .cards{display:flex;gap:56px;justify-content:center;flex-wrap:wrap;margin:16px 0 50px}
  .card{text-align:center;max-width:210px}
  .card img{width:155px;height:155px;border-radius:24px;object-fit:cover;display:block;margin:0 auto 8px}
  .caption{margin-top:6px;font-size:13px;color:#333}
  @media (max-width:900px){ .nav-left,.nav-right{gap:20px} .cards{gap:32px} .card img{width:140px;height:140px} }
  .book-btn {
  display: inline-block;
  margin-top: 10px;
  padding: 8px 16px;
  background-color: #7f9cf5;
  color: #fff;
  border-radius: 8px;
  text-decoration: none;
  font-weight: 600;
  transition: background-color 0.2s ease;
}

.book-btn:hover {
  background-color: #5f7ae0;
}
  
</style>
</head>
<body>
<%@ include file="NavBar.html" %>
  

  <div class="icons-row">
    <span class="icon-btn">🔔</span>
    <span class="icon-btn">♡</span>
  </div>

  <section class="profile">
    <img class="avatar" src="${pageContext.request.contextPath}/Images/profile.jpg" alt="Profile"/>
    <span class="name">Sally Chew</span>
  </section>

  <div class="search-wrap">
    <div class="search">
      <span style="margin-right:8px">🔍</span>
      <input placeholder=""/>
    </div>
  </div>

  <section class="banner">
    <div class="banner-text" id="tBox">
      <h2 id="t1">We care about you</h2>
      <p id="t2">Select a service with us now</p>
    </div>
    <img class="slide active" src="${pageContext.request.contextPath}/Images/caregiver_banner.webp" alt="Banner 1">
    <img class="slide" src="${pageContext.request.contextPath}/Images/cleaning.png" alt="Banner 2">
    <img class="slide" src="${pageContext.request.contextPath}/Images/doctor.png" alt="Banner 3">
    <div class="dots">
      <span class="dot active"></span>
      <span class="dot"></span>
      <span class="dot"></span>
    </div>
  </section>

<!-- SERVICES SECTION -->
<div class="services-head">
  <div class="pill">Services</div>
</div>

<section class="cards">
  <!-- CAREGIVING -->
  <div class="card">
    <img src="../Images/caregiver_banner.webp" alt="Caregiving">
    <div><strong>CAREGIVING</strong></div>
    
    <a href="../Services/Caregiving/CaregiverFilter.html" class="book-btn">Book Service</a>
  </div>

  <!-- CLEANING -->
  <div class="card">
    <img src="../Images/cleaning.png" alt="Cleaning">
    <div><strong>CLEANING</strong></div>
    
    <a href="../Services/Cleaning/CleanerFilter.html" class="book-btn">Book Service</a>
  </div>

  <!-- DOCTOR APPOINTMENTS -->
  <div class="card">
    <img src="../Images/doctor.png" alt="Doctor Appointments">
    <div><strong>DOCTOR APPOINTMENTS</strong></div>
    
    <a href="../Services/DoctorAppt/DoctorFilter.html" class="book-btn">Book Service</a>
  </div>
</section>


  <div style="text-align:center;margin-bottom:30px">
    <a class="nav-link" href="HomePage.html" style="color:#3366cc;text-decoration:underline">Go to HTML version</a>
  </div>

<script>
  const slides = document.querySelectorAll('.slide');
  const dots = document.querySelectorAll('.dot');
  const title = document.getElementById('t1');
  const sub   = document.getElementById('t2');
  const titles = ['We care about you','We care about you','We care about you'];
  const subs   = ['Select a service with us now','Select a service with us now','Select a service with us now'];
  let i=0;
  function show(k){
    slides.forEach((s,idx)=>s.classList.toggle('active', idx===k));
    dots.forEach((d,idx)=>d.classList.toggle('active', idx===k));
    title.textContent=titles[k]; sub.textContent=subs[k];
  }
  function next(){ i=(i+1)%slides.length; show(i); }
  let timer=setInterval(next,4000);
  dots.forEach((d,idx)=>d.addEventListener('click',()=>{clearInterval(timer);i=idx;show(i);timer=setInterval(next,4000)}));
</script>
</body>
</html>
