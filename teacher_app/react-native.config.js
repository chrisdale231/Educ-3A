module.exports = {
  dependencies: {
    '@dr.pogodin/react-native-fs': {
      platforms: {
        // RNFS supplies the writable Windows document path. Android uses the
        // app-private files directory directly and does not need this module.
        android: null,
      },
    },
  },
};
