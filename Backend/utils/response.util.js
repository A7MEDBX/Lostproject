Success = (res, message, data = null, status = 200) => {
  return res.status(status).json({
    success: true,
    message,
    data
  });
};

ErrorResponse = (res, message, errors = null, status = 400) => {
  return res.status(status).json({
    success: false,
    message,
    errors
  });
};
module.exports = {
    Success,
    ErrorResponse
}