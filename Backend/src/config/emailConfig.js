import nodemailer from "nodemailer";
import fs from "fs";
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

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

export const sendEmailWithAttachment = async ({ to, subject, text, attachmentPath, attachmentName }) => {
  const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS
    }
  });

  const mailOptions = {
    from: `"Dyslexia App" <${process.env.EMAIL_USER}>`,
    to,
    subject,
    text,
    attachments: [
      {
        filename: attachmentName,
        content: fs.createReadStream(attachmentPath)
      }
    ]
  };

  await transporter.sendMail(mailOptions);
};

export default sendOTPEmail;

