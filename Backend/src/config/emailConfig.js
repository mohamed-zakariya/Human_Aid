import nodemailer from "nodemailer";
import fs from "fs";
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

export const sendParentWelcomeEmail = async (email, name) => {
  const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS
    }
  });

  const mailOptions = {
    from: process.env.EMAIL_USER,
    to: email,
    subject: "Welcome to LexFix - Your Partner in Your Child's Learning Journey",
    html: `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body {
            margin: 0;
            padding: 0;
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            color: #333333;
          }
          .email-container {
            max-width: 600px;
            margin: 0 auto;
            background-color: #ffffff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
          }
          .header {
            background-color: #6a0dad; /* Purple */
            color: #ffffff;
            text-align: center;
            padding: 20px 0;
            border-top-left-radius: 8px;
            border-top-right-radius: 8px;
          }
          .content {
            padding: 20px;
            line-height: 1.6;
          }
          .footer {
            text-align: center;
            font-size: 12px;
            color: #777777;
            padding: 10px 0;
            border-top: 1px solid #eeeeee;
            margin-top: 20px;
          }
          .welcome-text {
            font-size: 20px;
            font-weight: bold;
            color: #6a0dad;
            margin-bottom: 20px;
          }
          .btn {
            display: inline-block;
            padding: 12px 24px;
            margin: 20px 0;
            color: #ffffff;
            background-color: #6a0dad;
            text-decoration: none;
            border-radius: 5px;
            font-size: 16px;
            font-weight: bold;
          }
          .feature {
            margin: 15px 0;
            padding-left: 20px;
            border-left: 3px solid #6a0dad;
          }
        </style>
      </head>
      <body>
        <div class="email-container">
          <div class="header">
            <h1>Welcome to LexFix!</h1>
          </div>
          <div class="content">
            <p class="welcome-text">Dear ${name},</p>
            
            <p>Thank you for choosing LexFix to support your child's dyslexia development. We're honored to partner with you in this important journey.</p>
            
            <div class="feature">
              <h3>What You Can Expect:</h3>
              <p>• <strong>Weekly Progress Reports</strong> - Track your child's improvement</p>
              <p>• <strong>Personalized Learning</strong> - Tailored to your child's needs</p>
              <p>• <strong>Safe Environment</strong> - Child-friendly and secure platform</p>
            </div>
            
            <p>As a parent on LexFix, you'll have access to:</p>
            <ul>
              <li>Detailed analytics of your child's progress</li>
              <li>Ability to monitor learning patterns</li>
              <li>Tools to support your child's practice at home</li>
            </ul>
            
            <p>We're committed to making Arabic learning engaging, effective, and rewarding for your child.</p>
            
            <p>If you have any questions about our platform or how to best support your child's learning, our support team is always here to help.</p>
            
            <p>Welcome aboard!</p>
            
            <p>Warm regards,<br>
            <strong>The LexFix Team</strong></p>
          </div>
          <div class="footer">
            <p>© 2025 LexFix. All rights reserved.</p>
            <p>You're receiving this email because you registered as a parent on LexFix.</p>
          </div>
        </div>
      </body>
      </html>
    `,
  };

  await transporter.sendMail(mailOptions);
};

export const sendWelcomeEmail = async (email, name) => {
  const mailOptions = {
    from: process.env.EMAIL_USER,
    to: email,
    subject: "Welcome to LexFix!",
    html: `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body {
            margin: 0;
            padding: 0;
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            color: #333333;
          }
          .email-container {
            max-width: 600px;
            margin: 0 auto;
            background-color: #ffffff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
          }
          .header {
            background-color: purple;
            color: #ffffff;
            text-align: center;
            padding: 20px 0;
            border-top-left-radius: 8px;
            border-top-right-radius: 8px;
          }
          .content {
            padding: 20px;
            line-height: 1.6;
            text-align: center;
          }
          .footer {
            text-align: center;
            font-size: 12px;
            color: #777777;
            padding: 10px 0;
          }
          .welcome-text {
            font-size: 20px;
            font-weight: bold;
            color: #333;
          }
          .btn {
            display: inline-block;
            padding: 10px 20px;
            margin: 20px 0;
            color: #ffffff;
            background-color: #4CAF50;
            text-decoration: none;
            border-radius: 5px;
            font-size: 16px;
          }
        </style>
      </head>
      <body>
        <div class="email-container">
          <div class="header">
            <h1>Welcome LexFix!</h1>
          </div>
          <div class="content">
            <p class="welcome-text">Hello, ${name}!</p>
            <p>We are thrilled to have you join our community.</p>
            <p>Our app is designed to help improve Arabic language skills in a fun and engaging way.</p>
            <p>Start exploring now!</p>
            <p>If you have any questions, feel free to reach out to our support team.</p>
            <p>Best regards,<br>The Team</p>
          </div>
          <div class="footer">
            <p>© 2025 Your Company. All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
    `,
  };

  await transporter.sendMail(mailOptions);
};

export const sendOTPEmail = async (email, otp, name) => {
  const mailOptions = {
    from: process.env.EMAIL_USER,
    to: email,
    subject: "Password Reset OTP",
    html: `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body {
            margin: 0;
            padding: 0;
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            color: #333333;
          }
          .email-container {
            max-width: 600px;
            margin: 0 auto;
            background-color: #ffffff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
          }
          .header {
            background-color: purple;
            color: #ffffff;
            text-align: center;
            padding: 20px 0;
            border-top-left-radius: 8px;
            border-top-right-radius: 8px;
          }
          .content {
            padding: 20px;
            line-height: 1.6;
          }
          .footer {
            text-align: center;
            font-size: 12px;
            color: #777777;
            padding: 10px 0;
          }
          .otp-box {
            display: inline-block;
            background-color: #f8f8f8;
            color: #333;
            font-size: 24px;
            font-weight: bold;
            padding: 10px;
            border-radius: 5px;
            margin: 20px 0;
          }
        </style>
      </head>
      <body>
        <div class="email-container">
          <div class="header">
            <h1>Password Reset Request</h1>
          </div>
          <div class="content">
            <p>Hello, <em style="color: rgb(21, 128, 235);"></em></p>
            <p>Use the OTP below to reset your password. This OTP is valid for 10 minutes.</p>
            <div class="otp-box">${otp}</div>
            <p>If you did not request this, please ignore this email.</p>
            <p>Best regards,<br>The Team</p>
          </div>
          <div class="footer">
            <p>© 2025 Your Company. All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
    `,
  };

  await transporter.sendMail(mailOptions);
};

export const sendEmailWithAttachment = async ({ 
  to, 
  subject, 
  text, 
  attachmentPath, 
  attachmentName, 
  attachments // New parameter for multiple attachments
}) => {
  const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS
    }
  });

  const mailOptions = {
    from: `"LexFix App" <${process.env.EMAIL_USER}>`,
    to,
    subject,
    text,
    attachments: []
  };

  // Handle single attachment (backward compatible)
  if (attachmentPath && attachmentName) {
    mailOptions.attachments.push({
      filename: attachmentName,
      content: fs.createReadStream(attachmentPath)
    });
  }

  // Handle multiple attachments
  if (attachments && attachments.length > 0) {
    for (const attachment of attachments) {
      mailOptions.attachments.push({
        filename: attachment.name,
        content: fs.createReadStream(attachment.path)
      });
    }
  }

  await transporter.sendMail(mailOptions);
};

export const sendInactivityEmail = async (email, recipientType, name, lastActiveDate, childName = null) => {
  const formattedDate = new Date(lastActiveDate).toLocaleDateString("en-US", {
    year: 'numeric', month: 'long', day: 'numeric'
  });

  const subject =
    recipientType === "adult"
      ? "We Miss You on LexFix!"
      : "Your Child's Progress Needs Attention";

  const message = recipientType === "adult"
    ? `<p>We noticed you haven’t been active on LexFix since <strong>${formattedDate}</strong>.</p>
       <p>Consistent practice is key to improving your skills. We encourage you to log back in and continue your journey!</p>`
    : `<p>We noticed that your child, <strong>${childName}</strong>, hasn’t been active on LexFix since <strong>${formattedDate}</strong>.</p>
       <p>Regular use of LexFix is essential for their learning progress. We recommend checking in and encouraging them to continue their learning journey.</p>`;

  const mailOptions = {
    from: `"LexFix App" <${process.env.EMAIL_USER}>`,
    to: email,
    subject: subject,
    html: `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body {
            margin: 0;
            padding: 0;
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            color: #333;
          }
          .email-container {
            max-width: 600px;
            margin: 0 auto;
            background-color: #ffffff;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
          }
          .header {
            background-color: #6a0dad;
            color: white;
            padding: 20px;
            text-align: center;
            border-top-left-radius: 10px;
            border-top-right-radius: 10px;
          }
          .content {
            padding: 20px;
          }
          .btn {
            display: inline-block;
            padding: 12px 24px;
            margin-top: 20px;
            background-color: #6a0dad;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            font-weight: bold;
          }
          .footer {
            margin-top: 30px;
            text-align: center;
            font-size: 12px;
            color: #888;
          }
        </style>
      </head>
      <body>
        <div class="email-container">
          <div class="header">
            <h2>We Miss You at LexFix</h2>
          </div>
          <div class="content">
            <p>Dear ${name},</p>
            ${message}
            <a href="https://your-lexfix-app-link.com" class="btn">Return to LexFix</a>
            <p style="margin-top: 30px;">Warm regards,<br/>The LexFix Team</p>
          </div>
          <div class="footer">
            <p>© 2025 LexFix. All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
    `
  };

  await transporter.sendMail(mailOptions);
};
