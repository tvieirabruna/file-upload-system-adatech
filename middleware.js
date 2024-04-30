import { NextResponse } from 'next/server';

export function middleware(req) {
  const res = NextResponse.next();

  res.headers.set('Access-Control-Allow-Origin', '*');  // Allowed origin(s)
  res.headers.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');  // Allowed methods
  res.headers.set('Access-Control-Allow-Headers', '*');  // Allowed headers
  res.headers.set('Access-Control-Max-Age', '3600');  // Cache duration for preflight requests

  return res;
}
