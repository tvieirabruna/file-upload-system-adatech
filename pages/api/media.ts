import type { NextApiRequest, NextApiResponse } from "next";
import S3 from "aws-sdk/clients/s3";

const s3 = new S3({
  apiVersion: "2006-03-01",
  accessKeyId: process.env.ACCESS_KEY,
  secretAccessKey: process.env.SECRET_KEY,
  region: process.env.REGION,
  signatureVersion: "v4",
});

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse
) {
  if (req.method === 'OPTIONS') {
    // Handle preflight
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', '*');
    res.status(200).end();  // Terminate the preflight response
    return;
  }
  
  const contentType = (req.query.fileType as string)
  const contentName = (req.query.fileName as string)
  const Key = contentName;

  const s3Params = {
    Bucket: process.env.BUCKET_NAME,
    Key,
    Expires: 60,
    ContentType: contentType,
  };

  const uploadUrl = s3.getSignedUrl("putObject", s3Params);

  res.status(200).json({
    uploadUrl,
    status: "success",
    message: `Upload realizado com sucesso!`
  });
}
